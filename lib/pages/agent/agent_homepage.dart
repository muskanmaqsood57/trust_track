import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_up/config/up_config.dart';
import 'package:flutter_up/locator.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:flutter_up/widgets/up_circualar_progress.dart';
import 'package:flutter_up/widgets/up_scaffold.dart';
import 'package:flutter_up/widgets/up_text.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/services/auth_service.dart';
import 'package:trust_track/widget/appbar.dart';
import 'package:trust_track/widget/home_card_widget.dart';

class AgentHomePage extends StatefulWidget {
  const AgentHomePage({super.key});

  @override
  State<AgentHomePage> createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String agentName = "";
  bool isLoading = true;
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _auth = AuthService();
  var userData = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    userData = await _auth.getUserData() ?? {};
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return UpScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: customAppBar(context, 'Trust Track'),
      body: SafeArea(
        child: isLoading
            ? const Center(child: UpCircularProgress())
            : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UpText(
                                "Hello ${userData['name'].split(" ")[0]},",
                                style: UpStyle(
                                  textSize: 25,
                                  textFontFamily: 'Sora',
                                ),
                              ),
                              UpText(
                                "Manage Smarter, Not Harder",
                                style: UpStyle(
                                  textSize: 13,
                                  textColor: UpConfig.of(
                                    context,
                                  ).theme.baseColor.shade500,
                                  textFontFamily: 'Poppins',
                                ),
                              ),
                              UpText(
                                "ID: ${userData['user_id']}",
                                style: UpStyle(
                                  textSize: 12,
                                  textColor: UpConfig.of(
                                    context,
                                  ).theme.baseColor.shade500,
                                  textFontFamily: 'Sora',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      HomeCardWidget(
                        icon: Icons.group,
                        title: "Client Management",
                        iconColor: UpConfig.of(context).theme.primaryColor,
                        onTap: () {
                          ServiceManager<UpNavigationService>().navigateToNamed(
                            Routes.clientManagementPage,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      HomeCardWidget(
                        icon: Icons.receipt_long_rounded,
                        title: "Records",
                        iconColor: UpConfig.of(context).theme.primaryColor,
                        onTap: () {
                          ServiceManager<UpNavigationService>().navigateToNamed(
                            Routes.agentRecordsPage,
                            extra: {'agentId': userData['user_id']},
                          );
                        },
                      ),
              
                      const SizedBox(height: 16),
                      HomeCardWidget(
                        icon: Icons.policy,
                        title: "Policies",
                        iconColor: UpConfig.of(context).theme.primaryColor,
                        onTap: () {
                          ServiceManager<UpNavigationService>().navigateToNamed(
                            Routes.policyPage,
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ),
      ),
    );
  }
}
