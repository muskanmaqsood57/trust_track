import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_up/config/up_config.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:flutter_up/widgets/up_circualar_progress.dart';
import 'package:flutter_up/widgets/up_scaffold.dart';
import 'package:flutter_up/widgets/up_text.dart';
import 'package:trust_track/services/auth_service.dart';
import 'package:trust_track/widget/appbar.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
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
      appBar: customAppBar(context, 'Trust Track', userData['name'] ?? ''),
      body: SafeArea(
        child: isLoading
            ? const Center(child: UpCircularProgress())
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Center(
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
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
