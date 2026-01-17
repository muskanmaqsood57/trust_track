import 'package:flutter/material.dart';
import 'package:flutter_up/config/up_config.dart';
import 'package:flutter_up/locator.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/models/policy.dart';
import 'package:trust_track/services/auth_service.dart';
import 'package:trust_track/services/policies_services.dart';
import 'package:trust_track/services/subscription_service.dart';
import 'package:trust_track/widget/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PoliciesPage extends StatefulWidget {
  final Object? extra;
  const PoliciesPage({super.key, this.extra});

  @override
  State<PoliciesPage> createState() => _PoliciesPageState();
}

class _PoliciesPageState extends State<PoliciesPage> {
  final PolicyService _policyService = PolicyService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SubscriptionService _subscriptionService = SubscriptionService();
  Set<String> _subscribedPolicyIds = {}; // store ids of subscribed policies

  bool _isLoading = true;
  List<Policy> _policies = [];
  String _userRole = "";
  String? _userId;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getUserRole();
    await _loadPolicies();
    await _getUserSubscriptions();
    await _loadUserSubscriptions();
  }

  Future<void> _getUserRole() async {
    try {
      final userRole = await _authService.getUserRole();
      final userId = await _authService.getCurrentUserId();
      setState(() {
        _userRole = userRole ?? "";
        _userId = userId;
      });
    } catch (e) {
      debugPrint("Error getting user role: $e");
    }
  }

  Future<void> _loadPolicies() async {
    setState(() => _isLoading = true);
    try {
      final policies = await _policyService.getPolicies();
      setState(() {
        _policies = policies;
      });
    } catch (e) {
      debugPrint("Error loading policies: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserSubscriptions() async {
    try {
      final subs = await _subscriptionService.getUserSubscriptions();
      setState(() {
        _subscribedPolicyIds = subs.map((s) => s["policyId"] as String).toSet();
      });
    } catch (e) {
      debugPrint("Error loading subscriptions: $e");
    }
  }

  Future<void> _getUserSubscriptions() async {
    if (_userId == null) return;

    final snapshot = await _firestore
        .collection('user_policies')
        .where('userId', isEqualTo: _userId)
        .where('isSubscribed', isEqualTo: true)
        .get();

    setState(() {
      _subscribedPolicyIds = snapshot.docs
          .map((doc) => doc['policyId'] as String)
          .toSet();
    });
  }

  List<Policy> get _filteredPolicies {
    if (_searchQuery.isEmpty) return _policies;
    return _policies.where((p) {
      return p.name.toLowerCase().contains(_searchQuery) ||
          p.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _subscribeToPolicy(Policy policy) async {
    await _subscriptionService.subscribeToPolicy(
      policy.id,
      policy.name,
      double.tryParse(policy.price) ?? 0.0,
      policy.paymentCycle,
    );

    setState(() {
      _subscribedPolicyIds.add(policy.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Subscribed to ${policy.name}!")));
  }

  void _showAddPolicyDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final cycleController = TextEditingController();
    final commissionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.policy, color: Color(0xFF5D45DA), size: 32),
                      SizedBox(width: 8),
                      Text(
                        "Add New Policy",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _buildInputField(
                        controller: nameController,
                        label: "Policy Name",
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: descriptionController,
                        label: "Description",
                        icon: Icons.description_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: priceController,
                        label: "Price (Rs)",
                        icon: Icons.local_atm,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: cycleController,
                        label: "Payment Cycle",
                        icon: Icons.repeat,
                        hint: "e.g., Monthly or Yearly",
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: commissionController,
                        label: "Commission (%)",
                        icon: Icons.percent_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    spacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancel"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D45DA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _policyService.addPolicy(
                            nameController.text.trim(),
                            descriptionController.text.trim(),
                            priceController.text.trim(),
                            cycleController.text.trim(),
                            commissionController.text.trim(),
                          );
                          Navigator.pop(context);
                          _loadPolicies();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Policy"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D45DA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF5D45DA)),
        filled: true,
        fillColor: const Color(0xFFF8F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5D45DA), width: 1.5),
        ),
      ),
    );
  }

  void _showPaymentDialog(Policy policy) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * .9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 245, 245, 255),
                  Color.fromARGB(255, 230, 230, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🪪 Card Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5D45DA), Color(0xFF7E67F8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "VISA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "**** **** **** 1234",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "CARD HOLDER",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "VALID THRU",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "JOHN DOE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "12/28",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Demo Payment",
                  style: TextStyle(
                    fontFamily: "Sora",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF5D45DA),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your payment details to subscribe.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // 🧾 Input Fields
                TextField(
                  decoration: InputDecoration(
                    labelText: "Card Number",
                    prefixIcon: const Icon(
                      Icons.credit_card,
                      color: Color(0xFF5D45DA),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Expiry Date",
                          prefixIcon: const Icon(
                            Icons.date_range,
                            color: Color(0xFF5D45DA),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "CVV",
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF5D45DA),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 💰 Payment Info
                Text(
                  "Amount: Rs ${policy.price}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                    fontFamily: "Poppins",
                  ),
                ),

                const SizedBox(height: 20),

                // 🔘 Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _subscribeToPolicy(policy);
                      },
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text(
                        "Pay Now",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D45DA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Policies", backRoute: _userRole == "agent" ? Routes.agentHomeage : Routes.clientHomepage),
      body: Column(
        children: [
          // 🔍 Search bar + Add button row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Search Box takes available width
                Expanded(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search clients...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Action Buttons
                if (_userRole == "agent")
                  ElevatedButton.icon(
                    onPressed: _showAddPolicyDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Policy"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D45DA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                if (_userRole == "client")
                  ElevatedButton.icon(
                    onPressed: () {
                      ServiceManager<UpNavigationService>().navigateToNamed(
                        Routes.subscribedPolicyPage,
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text("My Subscriptions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D45DA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 🔄 Body content (policies list)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _policies.isEmpty
                ? const Center(child: Text("No policies found."))
                : ListView.builder(
                    itemCount: _filteredPolicies.length,
                    itemBuilder: (context, index) {
                      final policy = _filteredPolicies[index];
                      final isSubscribed = _subscribedPolicyIds.contains(
                        policy.id,
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.policy,
                            color: Color.fromARGB(255, 93, 69, 218),
                            size: 32,
                          ),
                          title: Wrap(
                            children: [
                              Text(
                                policy.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Sora",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "(${policy.paymentCycle})",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: "Sora",
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            policy.description,
                            style: const TextStyle(fontFamily: "Poppins"),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Rs ${policy.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_userRole == "client")
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed:
                                        _subscribedPolicyIds.contains(policy.id)
                                        ? null
                                        : () => _showPaymentDialog(
                                            policy,
                                          ), // show payment dialog before subscribing
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _subscribedPolicyIds.contains(policy.id)
                                          ? Colors.grey
                                          : const Color.fromARGB(
                                              255,
                                              93,
                                              69,
                                              218,
                                            ),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(80, 30),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      isSubscribed ? "Subscribed" : "Subscribe",
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ),
                                ),
                              if (_userRole == "agent")
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: UpConfig.of(
                                        context,
                                      ).theme.primaryColor,
                                    ),
                                    color: const Color.fromARGB(
                                      255,
                                      247,
                                      238,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      policy.commission,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: UpConfig.of(
                                          context,
                                        ).theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
