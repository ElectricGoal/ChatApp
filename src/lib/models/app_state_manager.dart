import 'dart:async';

import 'package:flutter/cupertino.dart';

class AppTab {
  static const int tab0 = 0;
  static const int tab1 = 1;
  static const int tab2 = 2;
}

class AppStateManager extends ChangeNotifier {
  bool _initialized = false;
  bool _loggedIn = false;
  bool _registered = false;
  bool _resetPass = false;

  int _selectedTab = AppTab.tab0;

  bool get isInitialized => _initialized;
  bool get isLoggedIn => _loggedIn;
  bool get isRegistered => _registered;
  bool get isResetPass => _resetPass;
  int get getSelectedTab => _selectedTab;

  void initializeApp() {
    Timer(
      const Duration(seconds: 2),
      () {
        _initialized = true;

        notifyListeners();
      },
    );
  }

  void login() {
    _loggedIn = true;
    _registered = true;

    notifyListeners();
  }

  void goToRegisterScreen() {
    _loggedIn = true;

    notifyListeners();
  }

  void returnToLogin() {
    _loggedIn = false;

    notifyListeners();
  }

  void register() {
    _registered = true;

    notifyListeners();
  }

  void resetPass(bool value) {
    _resetPass = value;

    notifyListeners();
  }

  void goToTab(index) {
    _selectedTab = index;

    notifyListeners();
  }

  void logout() {
    _initialized = false;
    _loggedIn = false;
    _registered = false;
    _selectedTab = AppTab.tab0;

    initializeApp();

    notifyListeners();
  }
}
