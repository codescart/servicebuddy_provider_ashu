import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthService {
  //region Email

  Future<bool> signUpWithEmailPassword({required UserData userData}) async {
    return await _auth.createUserWithEmailAndPassword(email: userData.email.validate(), password: DEFAULT_PASSWORD_FOR_FIREBASE).then((userCredential) async {
      User currentUser = userCredential.user!;
      String displayName = userData.firstName.validate() + userData.lastName.validate();

      userData.uid = currentUser.uid.validate();
      userData.email = currentUser.email.validate();
      userData.profileImage = currentUser.photoURL.validate();
      userData.displayName = displayName;
      userData.createdAt = Timestamp.now().toDate().toString();
      userData.updatedAt = Timestamp.now().toDate().toString();
      userData.playerId = getStringAsync(PLAYERID);

      log("Step 1 ${userData.toJson()}");

      return await setRegisterData(userData: userData);
    }).catchError((e) {
      log(e.toString());
      throw false;
    });
  }

  Future<UserData> signInWithEmailPassword({required String email}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: DEFAULT_PASSWORD_FOR_FIREBASE).then((value) async {
      final User user = value.user!;

      UserData userModel = await userService.getUser(email: user.email);
      await updateUserData(userModel);

      return userModel;
    }).catchError((e) async {
      return await userService.getUser(email: email).then((value) {
        return value;
      }).catchError((e) {
        throw USER_NOT_FOUND;
      });
    });
  }

  Future<void> updateUserData(UserData user) async {
    userService.updateDocument(
      {
        'player_id': getStringAsync(PLAYERID),
        'updatedAt': Timestamp.now(),
      },
      user.uid,
    );
  }

  Future<bool> setRegisterData({required UserData userData}) async {
    return await userService.addDocumentWithCustomId(userData.uid.validate(), userData.toJson()).then((value) async {
      return true;
    }).catchError((e) {
      throw false;
    });
  }

//endregion
}
