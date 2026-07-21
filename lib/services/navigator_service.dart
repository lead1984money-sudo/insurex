
import "package:flutter/material.dart";


enum NavigateType { pushNamed, pushNamedReplaced, pushNamedAndRemoveUntil }

class NavigationService {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }


  Future<dynamic> pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(routeName, (route) => false, arguments: arguments);
  }

  static Future<dynamic> navigateTo(
      String routeName, {
        Object? arguments,
        BuildContext? context,
        NavigateType navigateType = NavigateType.pushNamed,
      }) async {
    var isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context ?? navigatorKey.currentContext!, (route) {
      if (route.settings.name == routeName) {
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (isNewRouteSameAsCurrent &&
        navigateType != NavigateType.pushNamedAndRemoveUntil) {

      return Navigator.pushReplacementNamed(
        context ?? navigatorKey.currentContext!,
        routeName,
        arguments: arguments,
      );
    }

    switch (navigateType) {
      case NavigateType.pushNamed:
        return Navigator.pushNamed(
          context ?? navigatorKey.currentContext!,
          routeName,
          arguments: arguments,
        );
      case NavigateType.pushNamedReplaced:
        return Navigator.pushReplacementNamed(
          context ?? navigatorKey.currentContext!,
          routeName,
          arguments: arguments,
        );
      case NavigateType.pushNamedAndRemoveUntil:
        return Navigator.pushNamedAndRemoveUntil(
          context ?? navigatorKey.currentContext!,
          routeName,
              (route) => false,
          arguments: arguments,
        );
    }
  }


}
