import 'package:flutter/material.dart';
import 'package:chat_app/models/user.dart';

class ProfileManager extends ChangeNotifier {
  UserModel user = UserModel(
    uid: 'None',
    firstName: 'None',
    lastName: 'None',
    email: 'None',
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

  void logout() {
    user = UserModel(
      uid: 'None',
      firstName: 'None',
      lastName: 'None',
      email: 'None',
    );
  }
}
