import 'package:flutter_up/config/up_config.dart';
import 'package:flutter_up/dialogs/up_loading.dart';
import 'package:flutter_up/locator.dart';
import 'package:flutter_up/services/up_dialog.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:flutter_up/widgets/up_icon.dart';
import 'package:flutter_up/widgets/up_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_up/helpers/up_toast.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:flutter_up/validation/up_valdation.dart';
import 'package:flutter_up/widgets/up_button.dart';
import 'package:flutter_up/widgets/up_textfield.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String cnic = "",
      fullname = "",
      email = "",
      password = "",
      contactNumber = "",
      condition = "";
  String selectedRole = "agent";
  bool _passwordVisible = false;
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String loadingDialogCompleterId = ServiceManager<UpDialogService>()
          .showDialog(
            context,
            UpLoadingDialog(),
            data: {'text': 'Signing Up...'},
          );

      final res = await _auth.signUp(
        name: fullname.trim(),
        email: email.trim(),
        password: password.trim(),
        cnic: cnic.trim(),
        contactNumber: contactNumber.trim(),
        role: selectedRole,
      );

      if (context.mounted) {
        ServiceManager<UpDialogService>().completeDialog(
          // ignore: use_build_context_synchronously
          context: context,
          completerId: loadingDialogCompleterId,
          result: null,
        );
      }

      if (res!["error"] == null) {
        UpToast.showToast(
          context: context,
          text: "Account created successfully!",
        );

        // Navigate to homepage
        ServiceManager<UpNavigationService>().navigateToNamed(Routes.initial);
      } else {
        // Show error
        UpToast.showToast(
          context: context,
          text: "Signup Failed: ${res["error"]}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              UpText(
                "Create",
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
              SizedBox(height: 8),
              UpText(
                "Enter your details to sign up.",
                style: UpStyle(textColor: Colors.grey.shade700, textSize: 13),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: UpTextField(
                  style: UpStyle(
                    textfieldBorderRadius: 8,
                    textfieldFilledColor: Colors.white,
                    textfieldLabelColor: Colors.grey,
                    textfieldBorderColor: Colors.grey,
                    textfieldBorderWidth: 1,
                    textfieldLabelSize: 12,
                  ),
                  label: 'Full name',
                  validation: UpValidation(isRequired: true),
                  onSaved: (input) => fullname = input!,
                  suffixIcon: UpIcon(
                    icon: Icons.person_outlined,
                    style: UpStyle(iconColor: Colors.grey.shade700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: UpTextField(
                  style: UpStyle(
                    textfieldBorderRadius: 8,
                    textfieldFilledColor: Colors.white,
                    textfieldLabelColor: Colors.grey,
                    textfieldBorderColor: Colors.grey,
                    textfieldBorderWidth: 1,
                    textfieldLabelSize: 12,
                  ),
                  label: 'Email',
                  validation: UpValidation(isRequired: true, isEmail: true),
                  onSaved: (input) => email = input!,
                  suffixIcon: UpIcon(
                    icon: Icons.email_outlined,
                    style: UpStyle(iconColor: Colors.grey.shade700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: UpTextField(
                  style: UpStyle(
                    textfieldBorderRadius: 8,
                    textfieldFilledColor: Colors.white,
                    textfieldLabelColor: Colors.grey,
                    textfieldBorderColor: Colors.grey,
                    textfieldBorderWidth: 1,
                    textfieldLabelSize: 12,
                  ),
                  label: 'Contact Number',
                  validation: UpValidation(isRequired: true),
                  onSaved: (input) => contactNumber = input!,
                  suffixIcon: UpIcon(
                    icon: Icons.phone_outlined,
                    style: UpStyle(iconColor: Colors.grey.shade700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: UpTextField(
                  style: UpStyle(
                    textfieldBorderRadius: 8,
                    textfieldFilledColor: Colors.white,
                    textfieldLabelColor: Colors.grey,
                    textfieldBorderColor: Colors.grey,
                    textfieldBorderWidth: 1,
                    textfieldLabelSize: 12,
                  ),
                  validation: UpValidation(minLength: 6),
                  label: "CNIC Number",
                  onSaved: (input) => cnic = input!,
                  suffixIcon: UpIcon(
                    icon: Icons.person_outlined,
                    style: UpStyle(iconColor: Colors.grey.shade700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: UpTextField(
                  style: UpStyle(
                    textfieldBorderRadius: 8,
                    textfieldFilledColor: Colors.white,
                    textfieldLabelColor: Colors.grey,
                    textfieldBorderColor: Colors.grey,
                    textfieldBorderWidth: 1,
                    textfieldLabelSize: 12,
                  ),
                  suffixIcon: condition.isNotEmpty
                      ? SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              IconButton(
                                icon: UpIcon(
                                  icon: !_passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  style: UpStyle(
                                    iconColor: _passwordVisible
                                        ? UpConfig.of(
                                            context,
                                          ).theme.primaryColor
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
                        )
                      : UpIcon(
                          icon: Icons.lock_outline,
                          style: UpStyle(iconColor: Colors.grey.shade700),
                        ),
                  obscureText: !_passwordVisible,
                  label: 'Password',
                  validation: UpValidation(isRequired: true, minLength: 6),
                  maxLines: 1,
                  onSaved: (input) => password = input!,
                  onChanged: (input) => setState(() {
                    condition = input!;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Role",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: "agent",
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),
                        const Text(
                          "Agent",
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: "client",
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),
                        const Text(
                          "Client",
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: UpButton(
                    text: "Sign up",
                    style: UpStyle(
                      buttonBorderRadius: 10,
                      buttonTextSize: 16,
                      buttonTextWeight: FontWeight.bold,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Signup"),
                    ),
                    onPressed: () => _signup(),
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
