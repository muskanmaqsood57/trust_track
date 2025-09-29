import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_up/locator.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:flutter_up/widgets/up_circualar_progress.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/services/auth_service.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final AuthService _auth = AuthService();
  bool isLoading = true;
  Widget? targetPage;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user logged in → Go to login
      setState(() {
        ServiceManager<UpNavigationService>().navigateToNamed(
          Routes.loginSignup,
        );
        isLoading = false;
      });
    } else {
      // User logged in → check role
      String? role = await _auth.getUserRole();

      setState(() {
        if (role == "agent") {
          ServiceManager<UpNavigationService>().navigateToNamed(
            Routes.agentHomeage,
          );
        } else if (role == "client") {
          ServiceManager<UpNavigationService>().navigateToNamed(
            Routes.clientHomepage,
          );
        } else {
          ServiceManager<UpNavigationService>().navigateToNamed(
            Routes.loginSignup,
          ); // fallback
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: UpCircularProgress()));
  }
}
