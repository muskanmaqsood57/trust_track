import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/models/policy.dart';
import 'package:trust_track/services/auth_service.dart';
import 'package:trust_track/services/policies_services.dart';
import 'package:trust_track/services/subscription_service.dart';
import 'package:trust_track/widget/appbar.dart';

class SubscribedPoliciesPage extends StatefulWidget {
  const SubscribedPoliciesPage({super.key});

  @override
  State<SubscribedPoliciesPage> createState() => _SubscribedPoliciesPageState();
}

class _SubscribedPoliciesPageState extends State<SubscribedPoliciesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  String? _userId;
  bool _isLoading = true;
  List<Policy> _subscribedPolicies = [];

  @override
  void initState() {
    super.initState();
    _loadSubscribedPolicies();
  }

  Future<void> _loadSubscribedPolicies() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      _userId = userId;

      final snapshot = await _firestore
          .collection('user_policies')
          .where('userId', isEqualTo: userId)
          .where('isSubscribed', isEqualTo: true)
          .get();
      final List<Policy> policies = [];

      for (var doc in snapshot.docs) {
        final policyId = doc['policyId'];
        final policy = await PolicyService().getPolicyById(policyId);

        if (policy != null) {
          policies.add(policy);
        }
      }

      setState(() {
        _subscribedPolicies = policies;
      });
    } catch (e) {
      debugPrint("Error loading subscriptions: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🟥 You can handle it directly here
  Future<void> _cancelSubscription(Policy policy) async {
  try {
    // 1️⃣ Update user_policies
    final userPolicyQuery = await _firestore
        .collection('user_policies')
        .where('userId', isEqualTo: _userId)
        .where('policyId', isEqualTo: policy.id)
        .limit(1)
        .get();

    if (userPolicyQuery.docs.isNotEmpty) {
      await userPolicyQuery.docs.first.reference.update({
        'isSubscribed': false,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    }

    // 2️⃣ Update subscriptions collection
    final subscriptionQuery = await _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: _userId)
        .where('policyId', isEqualTo: policy.id)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (subscriptionQuery.docs.isNotEmpty) {
      await subscriptionQuery.docs.first.reference.update({
        'status': 'cancelled',
        'nextDueDate': null, // optional, clear next due date
        'amount': 0, // optional, if you want to reset
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    }

    // 3️⃣ Update local state
    setState(() {
      _subscribedPolicies.removeWhere((p) => p.id == policy.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled subscription for ${policy.name}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Subscribed Policies", backRoute: Routes.policyPage),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscribedPolicies.isEmpty
          ? const Center(child: Text("No active subscriptions."))
          : ListView.builder(
              itemCount: _subscribedPolicies.length,
              itemBuilder: (context, index) {
                final policy = _subscribedPolicies[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF928DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        collapsedIconColor: Colors.white,
                        iconColor: Colors.white,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.policy, color: Color(0xFF6C63FF)),
                        ),
                        title: Text(
                          policy.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Sora",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text(
                          "Tap to view details",
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: "Poppins",
                          ),
                        ),
                        children: [
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  policy.description.isNotEmpty
                                      ? policy.description
                                      : "No description available",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Price: ${policy.price} PKR",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                    Text(
                                      "Cycle: ${policy.paymentCycle}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                FutureBuilder<List<DateTime>>(
                                  future: _subscriptionService
                                      .getSubscriptionHistory(
                                        _userId!,
                                        policy.id,
                                      ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: LinearProgressIndicator(
                                          minHeight: 2,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError ||
                                        snapshot.data == null ||
                                        snapshot.data!.isEmpty) {
                                      return const Text(
                                        "No history available.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontFamily: "Poppins",
                                        ),
                                      );
                                    }

                                    final history = snapshot.data!;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Subscription History:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Sora",
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        ...history.map(
                                          (date) => Text(
                                            "• ${date.toLocal().toString().split('.')[0]}",
                                            style: const TextStyle(
                                              fontFamily: "Poppins",
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _cancelSubscription(policy),
                                    icon: const Icon(Icons.cancel),
                                    label: const Text("Cancel Subscription"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
