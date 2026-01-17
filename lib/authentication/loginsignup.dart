import 'package:flutter/material.dart';
import 'package:flutter_up/config/up_config.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:flutter_up/widgets/up_scaffold.dart';
import 'package:flutter_up/widgets/up_text.dart';
import 'package:trust_track/authentication/login.dart';
import 'package:trust_track/authentication/signup.dart';
import '../../constants.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  String _mode = Constant.authLogin;
  String route = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _gotoLogin() {
    setState(() {
      _mode = Constant.authLogin;
    });
  }

  _gotoSignup() {
    setState(() {
      _mode = Constant.authSignup;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return UpScaffold(
      scaffoldKey: _scaffoldKey,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔼 Logo
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: SizedBox(
                      height: 100,
                      width: 180,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // 🧾 Login or Signup Page
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _mode == Constant.authLogin
                          ? const LoginPage()
                          : const SignupPage(),
                    ),

                    // 🔁 Switch text
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UpText(
                            _mode == Constant.authLogin
                                ? "Don't have an account?"
                                : "Already have an account?",
                            style: UpStyle(
                              textColor: Color.fromRGBO(123, 123, 123, 1),
                              textSize: 13,
                              textFontFamily: 'Poppins',
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _mode == Constant.authLogin
                                ? _gotoSignup()
                                : _gotoLogin(),
                            child: UpText(
                              _mode == Constant.authLogin
                                  ? " Sign up"
                                  : " Sign in",
                              style: UpStyle(
                                textColor: UpConfig.of(
                                  context,
                                ).theme.primaryColor,
                                textSize: 13,
                                textWeight: FontWeight.bold,
                                textFontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
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
