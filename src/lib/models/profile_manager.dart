import 'package:flutter/material.dart';
import 'package:chat_app/models/user.dart';

UserModel kAnonymousUser = UserModel(
  uid: 'none',
  firstName: 'none',
  lastName: 'none',
  email: 'none',
  avatarUrl: 'none',
);

class ProfileManager extends ChangeNotifier {
  UserModel user = kAnonymousUser;

  UserModel get getUser => user;

  bool _didSelectUser = false;

  bool _darkMode = false;

  bool get didSelectUser => _didSelectUser;

  bool get darkMode => _darkMode;

  void onProfilePressed(bool selected) {
    _didSelectUser = selected;

    notifyListeners();
  }

  set darkMode(bool darkMode) {
    _darkMode = darkMode;

    notifyListeners();
  }

  void updateUserData(UserModel loggedInUser) {
    user = loggedInUser;
  }

  void updateAvatar(String picUrl) {
    //user.avatarUrl = picUrl;

    user.copyWith(avatarUrl: picUrl);

    notifyListeners();
  }

  void logout() {
    user = kAnonymousUser;
  }
}
