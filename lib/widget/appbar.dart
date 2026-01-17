import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_up/config/up_config.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:flutter_up/widgets/up_icon.dart';
import 'package:trust_track/services/auth_service.dart';
import 'package:trust_track/constants.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:flutter_up/locator.dart';

PreferredSizeWidget customAppBar(BuildContext context, String title, {String? backRoute}) {
  final user = FirebaseAuth.instance.currentUser;

  return AppBar(
    backgroundColor: const Color.fromARGB(255, 240, 239, 247),
      leading: backRoute != null ? Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ServiceManager<UpNavigationService>()
                  .navigateToNamed(backRoute);
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.5,
                    color: UpConfig.of(context).theme.baseColor.shade500,
                  ),
                  borderRadius: BorderRadius.circular(8)),
              child: UpIcon(
                icon: Icons.chevron_left_rounded,
                style: UpStyle(
                  iconSize: 22,
                  iconColor: UpConfig.of(context).theme.baseColor.shade500,
                ),
              ),
            ),
          ),
        ),
      ) : null,
    elevation: 0,
    title: GestureDetector(
      onTap: () async {
        final role = await AuthService().getUserRole();

        if (role == "agent") {
          ServiceManager<UpNavigationService>().navigateToNamed(
            Routes.agentHomeage,
          );
        } else if (role == "client") {
          ServiceManager<UpNavigationService>().navigateToNamed(
            Routes.clientHomepage,
          );
        } else {
          // fallback → if role not found, maybe go to login
          ServiceManager<UpNavigationService>().navigateToNamed(
            Routes.loginSignup,
          );
        }
      },
      child: SizedBox(
        width: 150,
        height: 90,
        child: Image.asset("assets/images/logo.png"),
      ),
    ),
    actions: [
      if (user != null) ...[
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await AuthService().logout();
              ServiceManager<UpNavigationService>().navigateToNamed(
                Routes.loginSignup,
              );
            } else if (value == 'settings') {}
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Color.fromARGB(255, 93, 69, 218)),
                  SizedBox(width: 8),
                  Text("Settings", style: TextStyle(fontFamily: 'Poppins')),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Color.fromARGB(255, 93, 69, 218)),
                  SizedBox(width: 8),
                  Text("Logout", style: TextStyle(fontFamily: 'Poppins')),
                ],
              ),
            ),
          ],
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(Icons.menu, color: Colors.deepPurple.shade700),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ] else ...[
        TextButton.icon(
          onPressed: () {
            ServiceManager<UpNavigationService>().navigateToNamed(
              Routes.loginSignup,
            );
          },
          icon: const Icon(
            Icons.login,
            color: Color.fromARGB(255, 93, 69, 218),
          ),
          label: const Text(
            "Login",
            style: TextStyle(color: Color.fromARGB(255, 93, 69, 218)),
          ),
        ),
      ],
      const SizedBox(width: 8),
    ],
  );
}
