import 'package:flutter/material.dart';
import 'package:flutter_up/config/up_config.dart';
import 'package:flutter_up/dialogs/up_loading.dart';
import 'package:flutter_up/helpers/up_toast.dart';
import 'package:flutter_up/locator.dart';
import 'package:flutter_up/services/up_dialog.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:flutter_up/validation/up_valdation.dart';
import 'package:flutter_up/widgets/up_button.dart';
import 'package:flutter_up/widgets/up_text.dart';
import 'package:flutter_up/widgets/up_textfield.dart';
import 'package:flutter_up/widgets/up_icon.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  String condition = "";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  final AuthService _auth = AuthService();

  bool isLoading = false; // 👈 added loading state

  _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true; // show loading
      });
      String loadingDialogCompleterId = ServiceManager<UpDialogService>()
          .showDialog(
            context,
            UpLoadingDialog(),
            data: {'text': 'Signing in...'},
          );

      final res = await _auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (context.mounted) {
        ServiceManager<UpDialogService>().completeDialog(
          // ignore: use_build_context_synchronously
          context: context,
          completerId: loadingDialogCompleterId,
          result: null,
        );
      }

      setState(() {
        isLoading = false; // hide loading after response
      });

      if (res!["error"] == null) {
        UpToast.showToast(context: context, text: "Login Successfully");
        ServiceManager<UpNavigationService>().navigateToNamed(Routes.initial);
      } else {
        UpToast.showToast(context: context, text: "Error: ${res["error"]}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Form(
        key: _formKey,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              UpText(
                "Sign in",
                style: UpStyle(
                  textSize: 28,
                  textWeight: FontWeight.bold,
                  textFontFamily: 'Sora',
                ),
              ),
              UpText(
                "your account",
                style: UpStyle(
                  textSize: 28,
                  textWeight: FontWeight.bold,
                  textFontFamily: 'Sora',
                ),
              ),
              const SizedBox(height: 8),
              UpText(
                "Enter your email and password to sign in.",
                style: UpStyle(textColor: Colors.grey.shade700, textSize: 13),
              ),
              const SizedBox(height: 8),

              // Email field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: UpTextField(
                  controller: _emailController,
                  label: 'Email',
                  validation: UpValidation(isRequired: true, isEmail: true),
                  onSaved: (input) => email = input ?? "",
                  style: UpStyle(
                    textfieldBorderRadius: 8,
                    textfieldFilledColor: Colors.white,
                    textfieldLabelColor: Colors.grey,
                    textfieldBorderColor: Colors.grey,
                    textfieldBorderWidth: 1,
                    textfieldLabelSize: 12,
                  ),
                  suffixIcon: UpIcon(
                    icon: Icons.email_outlined,
                    style: UpStyle(iconColor: Colors.grey.shade700),
                  ),
                ),
              ),

              // Password field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: UpTextField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: !_passwordVisible,
                  validation: UpValidation(isRequired: true, minLength: 6),
                  onSaved: (input) => password = input ?? "",
                  onChanged: (input) => setState(() {
                    condition = input ?? "";
                  }),
                  onFieldSubmitted: (_) async => await _login(),
                  style: UpStyle(
                    textfieldFilledColor: Colors.white,
                    textfieldBorderRadius: 8,
                    textfieldBorderWidth: 1,
                    textfieldLabelColor: Colors.grey,
                    textfieldBorderColor: Colors.grey,
                    textfieldLabelSize: 12,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: UpIcon(
                          icon: !_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          style: UpStyle(
                            iconColor: _passwordVisible
                                ? UpConfig.of(context).theme.primaryColor
                                : UpConfig.of(context).theme.basicColor,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      UpIcon(
                        icon: Icons.lock_outline,
                        style: UpStyle(iconColor: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),

              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: UpButton(
                    style: UpStyle(
                      buttonBorderRadius: 10,
                      buttonTextSize: 16,
                      buttonTextWeight: FontWeight.bold,
                    ),
                    text: "Sign in",
                    onPressed: isLoading ? () {} : _login,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
