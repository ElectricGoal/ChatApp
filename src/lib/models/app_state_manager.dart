import 'dart:async';

import 'package:flutter/cupertino.dart';

class AppTab {
  static const int chat = 0;
  static const int search = 1;
  static const int list = 2;
}

enum AppState {
  none,
  initialize,
  logIn,
  register,
  resetPass,
  home,
}

class AppStateManager extends ChangeNotifier {
  /// Review: can use enum instead of a bunch of bool
  /// E.g : [AppState]

  AppState _appState = AppState.initialize;

  AppState get currentAppState => _appState;

  int _selectedTab = AppTab.chat;

  /// Review; if the code above use one enum to describe
  /// current app state then you can reduce number of
  /// getter here.

  int get getSelectedTab => _selectedTab;

  void initializeApp() {
    Timer(
      const Duration(seconds: 2),
      () {
        _appState = AppState.logIn;

        notifyListeners();
      },
    );
  }

  void login() {
    _appState = AppState.home;

    notifyListeners();
  }

  void goToRegisterScreen(bool value) {
    if (value){
      _appState = AppState.register;
    }else{
      _appState = AppState.logIn;
    }
    

    notifyListeners();
  }

  void register() {
    _appState = AppState.home;

    notifyListeners();
  }

  void resetPass(bool value) {
    if (value) {
      _appState = AppState.resetPass;
    } else {
      _appState = AppState.logIn;
    }

    notifyListeners();
  }

  void goToTab(index) {
    _selectedTab = index;

    notifyListeners();
  }

  void logout() {
    _selectedTab = AppTab.chat;
    _appState = AppState.initialize;

    // Review: [initializeApp] will call notifyListener 2 seconds later.
    // What the point of the next [notifyListeners] call ?
    initializeApp();
  }
}