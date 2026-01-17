import 'package:flutter/material.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/services/policies_services.dart';
import 'package:trust_track/services/subscription_service.dart';
import 'package:trust_track/widget/appbar.dart';
import 'package:trust_track/models/policy.dart';
import 'package:flutter_up/widgets/up_text.dart';
import 'package:intl/intl.dart';

class ViewClientSubscriptionsPage extends StatefulWidget {
  final Object? extra;
  const ViewClientSubscriptionsPage({super.key, this.extra});

  @override
  State<ViewClientSubscriptionsPage> createState() =>
      _ViewClientSubscriptionsPageState();
}

class _ViewClientSubscriptionsPageState
    extends State<ViewClientSubscriptionsPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final PolicyService _policyService = PolicyService();

  bool isLoading = true;
  String clientId = "";
  List<Map<String, dynamic>> subscriptions = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    if (widget.extra != null &&
        (widget.extra as Map<String, dynamic>)["clientId"] != null) {
      clientId = (widget.extra as Map<String, dynamic>)["clientId"];

      final subs =
          await _subscriptionService.getUserSubscriptionsByUserId(clientId);

      List<Map<String, dynamic>> detailedSubs = [];

      for (var sub in subs) {
        final policyId = sub["policyId"];
        Policy? policy = await _policyService.getPolicyById(policyId);

        detailedSubs.add({...sub, "policyDetails": policy});
      }

      setState(() => subscriptions = detailedSubs);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Client Subscriptions", backRoute: Routes.clientManagementPage),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscriptions.isEmpty
              ? Center(
                  child: UpText(
                    "No subscriptions found.",
                    style: UpStyle(
                      textSize: 16,
                      textColor: Colors.grey,
                      textFontFamily: "Poppins",
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    final Policy? policy = sub["policyDetails"];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 22),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ============================
                          // Header - Policy Name
                          // ============================
                          UpText(
                            policy?.name ?? "Unknown Policy",
                            style: UpStyle(
                              textSize: 22,
                              textWeight: FontWeight.bold,
                              textFontFamily: "Sora",
                              textColor: const Color(0xFF1B1D28),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: sub["status"] == "active"
                                      ? Colors.green
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              UpText(
                                (sub["status"] ?? "N/A").toUpperCase(),
                                style: UpStyle(
                                  textSize: 13,
                                  textColor: Colors.black54,
                                  textFontFamily: "Poppins",
                                  textWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ============================
                          // Subscription Details Section
                          // ============================
                          UpText(
                            "Subscription Details",
                            style: UpStyle(
                              textSize: 16,
                              textFontFamily: "Sora",
                              textWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _detailRow("Payment Cycle", sub["paymentCycle"]),
                          _detailRow(
                              "Start Date", _formatDate(sub["startDate"])),
                          _detailRow(
                              "Next Due Date", _formatDate(sub["nextDueDate"])),

                          const SizedBox(height: 18),
                          Divider(color: Colors.grey[300], thickness: 1),

                          const SizedBox(height: 14),

                          // ============================
                          // Policy Details Section
                          // ============================
                          UpText(
                            "Policy Details",
                            style: UpStyle(
                              textSize: 16,
                              textFontFamily: "Sora",
                              textWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _detailRow("Price", policy?.price),
                          _detailRow("Commission", policy?.commission),
                          _detailRow("Description", policy?.description),

                          const SizedBox(height: 22),

                          // ============================
                          // SEND INVOICE BUTTON
                          // ============================
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _sendInvoice(sub, policy),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D45DA),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: UpText(
                                "Send Invoice",
                                style: UpStyle(
                                  textSize: 16,
                                  textFontFamily: "Poppins",
                                  textColor: Colors.white,
                                  textWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _detailRow(String title, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // important for multi-line
      children: [
        // Title
        SizedBox(
          width: 120, // fixed width for title (adjust as needed)
          child: UpText(
            title,
            style: UpStyle(
              textSize: 14,
              textFontFamily: "Poppins",
              textColor: Colors.black87,
              textWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Value
        Expanded(
          child: Text(
            value ?? "N/A",
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Poppins",
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.left, // wrap properly
          ),
        ),
      ],
    ),
  );
}


  String _formatDate(dynamic dateObj) {
  if (dateObj == null) return "N/A";

  try {
    DateTime dt;

    // if it's a Timestamp from Firestore
    if (dateObj.toDate != null) {
      dt = dateObj.toDate();
    } else if (dateObj is DateTime) {
      dt = dateObj;
    } else {
      dt = DateTime.parse(dateObj.toString());
    }

    // Format as 2 Dec 2025
    return DateFormat('d MMM yyyy').format(dt);
  } catch (e) {
    return dateObj.toString();
  }
}

  void _sendInvoice(Map<String, dynamic> sub, Policy? policy) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invoice sent successfully!")),
    );
  }
}
