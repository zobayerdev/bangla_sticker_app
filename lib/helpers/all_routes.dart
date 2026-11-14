import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sticker_flutter/features/home_screen/presentation/home_screen.dart';

final class Routes {
  static final Routes _routes = Routes._internal();

  Routes._internal();

  static Routes get instance => _routes;

  ///================== Auth ====================================
  static const splashScreen = '/splashScreen';
  static const logInScreen = '/logInScreen';
  static const signInScreen = '/signInScreen';
  static const signUpScreen = '/signUpScreen';
  static const notificationScreen = '/notificationScreen';
  static const homeScreen = '/homeScreen';
  static const bottomNavScreen = '/bottomNavScreen';
  static const supervisorNavScreen = '/supervisorNavScreen';
  static const supervisorNotificationScreen = '/supervisorNotificationScreen';
  static const supervisorPeopleScreen = '/supervisorPeopleScreen';
  static const supervisorStaffDetailScreen = '/supervisorStaffDetailScreen';
  static const supervisorTaskScreen = '/supervisorTaskScreen';
  static const supervisorReviewWorkScreen = '/supervisorReviewWorkScreen';
  static const supervisorRequestReworkScreen = '/supervisorRequestReworkScreen';
  static const supervisorReworkVerificationScreen =
      '/supervisorReworkVerificationScreen';
  static const supervisorRoomDetailScreen = '/supervisorRoomDetailScreen';
  static const supervisorSupplyDetailScreen = '/supervisorSupplyDetailScreen';
  static const supervisorIssueDetailScreen = '/supervisorIssueDetailScreen';
  static const supervisorProfileScreen = '/supervisorProfileScreen';
  static const supervisorProfileInfoScreen = '/supervisorProfileInfoScreen';
  static const supervisorChangePasswordScreen =
      '/supervisorChangePasswordScreen';
  static const supervisorPrivacyPolicyScreen = '/supervisorPrivacyPolicyScreen';
  static const supervisorTermsScreen = '/supervisorTermsScreen';
  static const supervisorHelpSupportScreen = '/supervisorHelpSupportScreen';
  static const supervisorHelpSupportFormScreen =
      '/supervisorHelpSupportFormScreen';
  static const supervisorPublicFeedbackScreen =
      '/supervisorPublicFeedbackScreen';
  static const supervisorFeedbackDetailScreen =
      '/supervisorFeedbackDetailScreen';
  static const supervisorMessageScreen = '/supervisorMessageScreen';
  static const supervisorNewMessageScreen = '/supervisorNewMessageScreen';
  static const supervisorMessagePreviewScreen =
      '/supervisorMessagePreviewScreen';
  static const supervisorHistoryScreen = '/supervisorHistoryScreen';
  static const supervisorCleaningHistoryScreen =
      '/supervisorCleaningHistoryScreen';
  static const supervisorCleaningRecordScreen =
      '/supervisorCleaningRecordScreen';
  static const supervisorReworkHistoryScreen = '/supervisorReworkHistoryScreen';
  static const supervisorIssueHistoryScreen = '/supervisorIssueHistoryScreen';
  static const navigationScreen = '/navigationScreen';
  static const findRoomScreen = '/findRoomScreen';
  static const shiftScreen = '/shiftScreen';
  static const taskListScreen = '/taskListScreen';
  static const completeTaskScreen = '/completeTaskScreen';
  static const reportIssueScreen = '/reportIssueScreen';
  static const supplyRequestScreen = '/supplyRequestScreen';
  static const endShiftScreen = '/endShiftScreen';
  static const endTaskScreen = '/endTaskScreen';
  static const shiftSummaryScreen = '/shiftSummaryScreen';
  static const historyScreen = '/historyScreen';
  static const reworkTaskScreen = '/reworkTaskScreen';
  static const completedAreaScreen = '/completedAreaScreen';
  static const profileScreen = '/profileScreen';
  static const editProfileScreen = '/editProfileScreen';
  static const changePasswordScreen = '/changePasswordScreen';
  static const privacyPolicyScreen = '/privacyPolicyScreen';
  static const termsScreen = '/termsScreen';
  static const helpSupportScreen = '/helpSupportScreen';
  static const contactScreen = '/contactScreen';
}

final class RouteGenerator {
  static final RouteGenerator _routeGenerator = RouteGenerator._internal();

  RouteGenerator._internal();

  static RouteGenerator get instance => _routeGenerator;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeScreen:
        if (Platform.isAndroid) {
          return FadedTransitionRoute(
            widget: const HomeScreen(),
            settings: settings,
          );
        } else {
          return CupertinoPageRoute(
            builder: (context) => const HomeScreen(),
            settings: settings,
          );
        }

      default:
        return _errorRoute(settings);
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    if (Platform.isAndroid) {
      return FadedTransitionRoute(
        widget: Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
        settings: settings,
      );
    } else {
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
    }
  }
}

class FadedTransitionRoute extends PageRouteBuilder {
  final Widget widget;
  @override
  final RouteSettings settings;

  FadedTransitionRoute({required this.widget, required this.settings})
    : super(
        settings: settings,
        reverseTransitionDuration: const Duration(milliseconds: 1),
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return widget;
            },
        transitionDuration: const Duration(milliseconds: 1),
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.ease),
                child: child,
              );
            },
      );
}

class ScreenTitle extends StatelessWidget {
  final Widget widget;

  const ScreenTitle({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: .5, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: widget,
    );
  }
}
