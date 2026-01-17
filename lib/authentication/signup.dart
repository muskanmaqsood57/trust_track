import 'package:cloud_firestore/cloud_firestore.dart';
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
      invitedUserId = "",
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

      Map<String, dynamic>? agentData;

      // 🔹 Step 1: Validate invited user (for clients only)
      if (selectedRole == "client") {
        if (invitedUserId.isEmpty) {
          UpToast.showToast(
            context: context,
            text: "Please enter your agent’s ID.",
          );
          return;
        }

        // Check if agent exists
        final query = await FirebaseFirestore.instance
            .collection("users")
            .where("user_id", isEqualTo: invitedUserId.trim())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          UpToast.showToast(
            context: context,
            text: "Invalid Agent ID. Please check and try again.",
          );
          return;
        }

        // 🔹 Step 2: Show confirmation dialog
        agentData = query.docs.first.data();
        bool confirmed = await _showAgentConfirmationDialog(context, agentData);

        if (!confirmed) {
          UpToast.showToast(
            context: context,
            text: "Signup cancelled by user.",
          );
          return;
        }
      }

      // 🔹 Step 3: Proceed with signup
      String loadingDialogCompleterId = ServiceManager<UpDialogService>()
          .showDialog(
            context,
            UpLoadingDialog(),
            data: {'text': 'Creating Account...'},
          );

      final res = await _auth.signUp(
        name: fullname.trim(),
        email: email.trim(),
        password: password.trim(),
        cnic: cnic.trim(),
        invitedUserId: invitedUserId.trim(),
        contactNumber: contactNumber.trim(),
        role: selectedRole,
      );

      if (context.mounted) {
        ServiceManager<UpDialogService>().completeDialog(
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
        ServiceManager<UpNavigationService>().navigateToNamed(Routes.initial);
      } else {
        UpToast.showToast(
          context: context,
          text: "Signup Failed: ${res["error"]}",
        );
      }
    }
  }

  Future<bool> _showAgentConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> agentData,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final joinedDate = agentData["joinedDate"] != null
                ? (agentData["joinedDate"] as Timestamp)
                      .toDate()
                      .toString()
                      .split(' ')
                      .first
                : "Unknown";

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🧑‍💼 Profile Circle
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Color.fromARGB(255, 216, 210, 245),
                      child: const Icon(
                        Icons.person_outline,
                        size: 40,
                        color:  Color(0xFF5D45DA),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Confirm Agent Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please confirm your referring agent’s information before proceeding.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🌟 Info Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Agent Name", agentData["name"]),
                          _infoRow("Email", agentData["email"]),
                          _infoRow("Joined Date", joinedDate),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Do you confirm this is your referring agent?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✨ Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5D45DA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 10,
                            ),
                            elevation: 2,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  // Small reusable row for cleaner info layout
  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
          Flexible(
            child: Text(
              value ?? "N/A",
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
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
              Visibility(
                visible: selectedRole == "client",
                child: Padding(
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
                    label: "Agent's ID",
                    onSaved: (input) => invitedUserId = input!,
                    suffixIcon: UpIcon(
                      icon: Icons.person_outlined,
                      style: UpStyle(iconColor: Colors.grey.shade700),
                    ),
                  ),
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
