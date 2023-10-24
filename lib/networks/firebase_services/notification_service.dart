import 'dart:convert';
import 'dart:io';

import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constant.dart';

class NotificationService {
  Future<void> sendPushNotifications(String title, String content, {String? id, String? image, String? receiverPlayerId}) async {
    Map req = {
      'headings': {
        'en': title,
      },
      'contents': {
        'en': content,
      },
      'big_picture': image.validate().isNotEmpty ? image.validate() : '',
      'large_icon': image.validate().isNotEmpty ? image.validate() : '',
      'small_icon': appLogo,
      /*'data': {
        'id': id,
      },*/

      'app_id': getStringAsync(ONESIGNAL_APP_ID_PROVIDER),
      'android_channel_id': getStringAsync(ONESIGNAL_CHANNEL_KEY_PROVIDER, defaultValue: ONESIGNAL_CHANNEL_ID),
      'include_player_ids': [receiverPlayerId],
      'android_group': APP_NAME,
    };
    var header = {
      HttpHeaders.authorizationHeader: 'Basic ${getStringAsync(ONESIGNAL_REST_API_KEY_PROVIDER, defaultValue: ONESIGNAL_REST_KEY)}',
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };

    Response res = await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      body: jsonEncode(req),
      headers: header,
    );

    log(res.statusCode);
    log(res.body);

    if (res.statusCode.isSuccessful()) {
      log("--- Notification Sent ---");
    } else {
      throw errorSomethingWentWrong;
    }
  }
}
