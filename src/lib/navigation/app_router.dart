import 'package:flutter/cupertino.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/screens.dart';

class AppRouter extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final AppStateManager appStateManager;
  final ProfileManager profileManager;

  AppRouter({
    required this.appStateManager,
    required this.profileManager,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    appStateManager.addListener(notifyListeners);
    profileManager.addListener(notifyListeners);
  }

  @override
  void dispose() {
    appStateManager.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _handlePopPage,
      pages: [
        if (appStateManager.currentAppState == AppState.initialize)
          InitializeScreen.page(),
        if (appStateManager.currentAppState == AppState.logIn)
          LoginScreen.page(),
        if (appStateManager.currentAppState == AppState.register)
          RegisterScreen.page(),
        if (appStateManager.currentAppState == AppState.resetPass)
          ResetPasswordScreen.page(),
        if (appStateManager.currentAppState == AppState.home)
          Home.page(appStateManager.getSelectedTab),
        if (profileManager.didSelectUser)
          ProfileScreen.page(profileManager.getUser),
      ],
    );
  }

  bool _handlePopPage(
    Route<dynamic> route,
    result,
  ) {
    if (!route.didPop(result)) {
      // 4
      return false;
    }
    if (route.settings.name == AppPages.resetPassPath) {
      appStateManager.resetPass(false);
    }
    if (route.settings.name == AppPages.registerPath) {
      appStateManager.goToRegisterScreen(false);
    }
    if (route.settings.name == AppPages.profilePath) {
      profileManager.onProfilePressed(false);
    }
    return true;
  }

  @override
  // ignore: avoid_returning_null_for_void
  Future<void> setNewRoutePath(configuration) async => null;
}
