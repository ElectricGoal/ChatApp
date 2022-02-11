import 'package:flutter/material.dart';
import 'package:chat_app/models/user.dart';

class ProfileManager extends ChangeNotifier {
  UserModel user = UserModel(
    uid: 'none',
    firstName: 'none',
    lastName: 'none',
    email: 'none',
    avatarUrl: 'none',
  );
  UserModel get getUser => user;

  bool _didSelectUser = false;

  bool _darkMode = false;

  bool get didSelectUser => _didSelectUser;

  bool get darkMode => _darkMode;

  void tapOnProfile(bool selected) {
    _didSelectUser = selected;

    notifyListeners();
  }

  set darkMode(bool darkMode) {
    _darkMode = darkMode;

    notifyListeners();
  }

  void getDataUser(UserModel loggedInUser) {
    user = loggedInUser;
  }

  void updateAvatar(String picUrl) {
    user.avatarUrl = picUrl;

    notifyListeners();
  }

  void logout() {
    user = UserModel(
      uid: 'none',
      firstName: 'none',
      lastName: 'none',
      email: 'none',
      avatarUrl: 'none',
    );
  }
}
