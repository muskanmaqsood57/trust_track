import 'package:flutter/material.dart';
import 'package:flutter_up/models/up_route.dart';
import 'package:flutter_up/models/up_router_state.dart';
import 'package:flutter_up/up_app.dart';
import 'package:trust_track/authentication/loginsignup.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/pages/agent/agent_homepage.dart';
import 'package:trust_track/pages/agent/agent_records_page.dart';
import 'package:trust_track/pages/agent/view_client_subscriptions_page.dart';
import 'package:trust_track/pages/client/client_homepage.dart';
import 'package:trust_track/pages/client_managment_page.dart';
import 'package:trust_track/pages/initial_page.dart';
import 'package:trust_track/pages/policies_page.dart';
import 'package:trust_track/pages/subscribed_policies_page.dart';
import 'package:trust_track/theme/light_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(textSelectionTheme: TextSelectionThemeData()),
      child: UpApp(
        theme: lightTheme,
        initialRoute: Routes.initial,
        upRoutes: [
          UpRoute(
            path: Routes.loginSignup,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return LoginSignupPage();
            },
            name: Routes.loginSignup,
          ),
          UpRoute(
            path: Routes.initial,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return InitialPage();
            },
            name: Routes.initial,
          ),
          UpRoute(
            path: Routes.agentHomeage,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return AgentHomePage();
            },
            name: Routes.agentHomeage,
          ),
          UpRoute(
            path: Routes.clientHomepage,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return ClientHomePage();
            },
            name: Routes.clientHomepage,
          ),
          UpRoute(
            path: Routes.clientManagementPage,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return ClientManagementPage();
            },
            name: Routes.clientManagementPage,
          ),
          UpRoute(
            path: Routes.policyPage,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return PoliciesPage(extra: state.extra);
            },
            name: Routes.policyPage,
          ),
          UpRoute(
            path: Routes.subscribedPolicyPage,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return SubscribedPoliciesPage();
            },
            name: Routes.subscribedPolicyPage,
          ),
          UpRoute(
            path: Routes.clientSubscriptionsPage,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return ViewClientSubscriptionsPage(extra: state.extra);
            },
            name: Routes.clientSubscriptionsPage,
          ),
          UpRoute(
            path: Routes.agentRecordsPage,
            pageBuilder: (BuildContext context, UpRouterState state) {
              return AgentRecordsPage(extra: state.extra);
            },
            name: Routes.agentRecordsPage,
          ),
        ],
        title: 'Trust Track',
      ),
    );
  }
}
