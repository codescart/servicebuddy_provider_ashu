import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/chat_message_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/screens/chat/components/chat_item_widget.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserChatScreen extends StatefulWidget {
  final UserData receiverUser;

  UserChatScreen({required this.receiverUser});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> with WidgetsBindingObserver {
  TextEditingController messageCont = TextEditingController();

  FocusNode messageFocus = FocusNode();

  UserData senderUser = UserData();

  late StreamSubscription _streamSubscription;

  int isReceiverOnline = 0;

  bool get isReceiverUserOnline => isReceiverOnline == 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    WidgetsBinding.instance.addObserver(this);

    OneSignal.shared.disablePush(true);

    if (widget.receiverUser.uid.validate().isEmpty) {
      await userService.getUser(email: widget.receiverUser.email.validate()).then((value) {
        widget.receiverUser.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    }

    senderUser = await userService.getUser(email: appStore.userEmail.validate());
    setState(() {});

    await chatServices.setUnReadStatusToTrue(senderId: appStore.uId.validate(), receiverId: widget.receiverUser.uid.validate()).catchError((e) {
      toast(e.toString());
    });

    _streamSubscription = chatServices.getReceiverUserIsOnline(receiverUserId: widget.receiverUser.uid.validate(), senderId: appStore.uId.validate()).listen((event) {
      isReceiverOnline = event.isOnline.validate();
      log("=======*=======*=======*=======*=======* $isReceiverOnline =======*=======*=======*=======*=======");
    });
  }

  //region Widget
  Widget _buildChatFieldWidget() {
    return Row(
      children: [
        AppTextField(
          textFieldType: TextFieldType.OTHER,
          controller: messageCont,
          textStyle: primaryTextStyle(),
          minLines: 1,
          onFieldSubmitted: (s) {
            sendMessages();
          },
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: inputDecoration(context).copyWith(hintText: languages.lblMessage, hintStyle: secondaryTextStyle()),
        ).expand(),
        8.width,
        Container(
          decoration: boxDecorationDefault(borderRadius: radius(80), color: primaryColor),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () {
              sendMessages();
            },
          ),
        )
      ],
    );
  }

  //endregion

  //region Methods
  Future<void> sendMessages() async {
    // If Message TextField is Empty.
    if (messageCont.text.trim().isEmpty) {
      messageFocus.requestFocus();
      return;
    }

    // Making Request for sending data to firebase
    ChatMessageModel data = ChatMessageModel();

    data.receiverId = widget.receiverUser.uid;
    data.senderId = appStore.uId;
    data.message = messageCont.text;
    data.isMessageRead = isReceiverOnline == 1;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.createdAtTime = Timestamp.now();
    data.updatedAtTime = Timestamp.now();
    data.messageType = MessageType.TEXT.name;

    messageCont.clear();

    await chatServices.addMessage(data).then((value) async {
      log("--Message Successfully Added--");

      // /// Send Notification
      // if (isReceiverOnline == 1) {
      //   NotificationService()
      //       .sendPushNotifications(appStore.userFullName, data.message.validate(),
      //           uid: senderUser.uid.validate(), email: senderUser.email.validate(), receiverPlayerId: widget.receiverUser.playerId.validate())
      //       .catchError((e) {
      //     log("Notification Error ${e.toString()}");
      //   });
      // }

      await chatServices.addMessageToDb(senderRef: value, chatData: data, sender: senderUser, receiverUser: widget.receiverUser).then((value) {
        //
      }).catchError((e) {
        log(e.toString());
      });

      /// Save receiverId to Sender Doc.
      userService.saveToContacts(senderId: appStore.uId, receiverId: widget.receiverUser.uid.validate()).then((value) => log("---ReceiverId to Sender Doc.---")).catchError((e) {
        log(e.toString());
      });

      /// Save senderId to Receiver Doc.
      userService.saveToContacts(senderId: widget.receiverUser.uid.validate(), receiverId: appStore.uId).then((value) => log("---SenderId to Receiver Doc.---")).catchError((e) {
        log(e.toString());
      });

      /*  /// Unread count for badge
         chatServices.setUnreadCount(senderId: widget.receiverUser.uid.validate(), receiverId: appStore.uId, status: isReceiverOnline == 1 ? 1 : 0);
      */
    }).catchError((e) {
      log(e.toString());
    });
  }

  //endregion

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      OneSignal.shared.disablePush(false);
    }

    if (state == AppLifecycleState.paused) {
      OneSignal.shared.disablePush(false);
    }
    if (state == AppLifecycleState.resumed) {
      OneSignal.shared.disablePush(true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    OneSignal.shared.disablePush(false);
    WidgetsBinding.instance.removeObserver(this);

    chatServices.setOnlineCount(senderId: appStore.uId, receiverId: widget.receiverUser.uid.validate(), status: 0);

    _streamSubscription.cancel();

    setStatusBarColor(transparentColor, statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.dark);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        backWidget: BackWidget(),
        color: context.primaryColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(statusBarColor: context.primaryColor, statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light),
        titleWidget: Text(widget.receiverUser.firstName.validate(), style: TextStyle(color: white)),
        actions: [
          PopupMenuButton(
            onSelected: (index) {
              if (index == 0) {
                showConfirmDialogCustom(
                  context,
                  primaryColor: context.primaryColor,
                  title: languages.clearChatMessage,
                  positiveText: languages.lblYes,
                  negativeText: languages.lblNo,
                  onAccept: (c) async {
                    appStore.setLoading(true);
                    await chatServices.clearAllMessages(senderId: appStore.uId, receiverId: widget.receiverUser.uid.validate()).then((value) {
                      toast(languages.chatCleared);
                      hideKeyboard(context);
                    }).catchError((e) {
                      toast(e);
                    });
                    appStore.setLoading(false);
                  },
                );
              }
            },
            icon: Icon(Icons.more_vert_sharp, color: Colors.white),
            itemBuilder: (context) {
              List<PopupMenuItem> list = [];
              list.add(
                PopupMenuItem(
                  value: 0,
                  child: Text(languages.clearChat, style: primaryTextStyle()),
                ),
              );
              return list;
            },
          )
        ],
      ),
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(chat_default_wallpaper).image,
                  fit: BoxFit.cover,
                  colorFilter: appStore.isDarkMode ? ColorFilter.mode(Colors.black54, BlendMode.luminosity) : ColorFilter.mode(primaryColor, BlendMode.overlay),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 80),
              child: FirestorePagination(
                reverse: true,
                isLive: true,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                physics: BouncingScrollPhysics(),
                query: chatServices.chatMessagesWithPagination(senderId: appStore.uId.validate(), receiverUserId: widget.receiverUser.uid.validate()),
                initialLoader: LoaderWidget(),
                limit: PER_PAGE_CHAT_LIST_COUNT,
                onEmpty: Text(languages.noDataFound).center(),
                shrinkWrap: true,
                viewType: ViewType.list,
                itemBuilder: (context, snap, index) {
                  ChatMessageModel data = ChatMessageModel.fromJson(snap.data() as Map<String, dynamic>);
                  data.isMe = data.senderId == appStore.uId;

                  return ChatItemWidget(chatItemData: data);
                },
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildChatFieldWidget(),
            )
          ],
        ),
      ),
    );
  }
}
