import 'package:flutter/material.dart';
import 'package:flutter_up/locator.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:flutter_up/widgets/up_text.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:intl/intl.dart';
import 'package:trust_track/constants.dart';

import 'package:trust_track/services/subscription_service.dart';
import 'package:trust_track/services/policies_services.dart';
import 'package:trust_track/services/client_service.dart';
import 'package:trust_track/widget/appbar.dart';
import 'package:trust_track/models/policy.dart';

class AgentRecordsPage extends StatefulWidget {
  final Object? extra;
  const AgentRecordsPage({super.key, this.extra});

  @override
  State<AgentRecordsPage> createState() => _AgentRecordsPageState();
}

class _AgentRecordsPageState extends State<AgentRecordsPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final PolicyService _policyService = PolicyService();
  final ClientService _clientService = ClientService();

  bool isLoading = true;
  String agentId = "";

  // raw subscriptions with policy & client details
  List<Map<String, dynamic>> _records = [];

  // filters
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month; // 1..12, 0 means all

  // computed metrics
  int totalClients = 0;
  int totalPoliciesSold = 0;
  double totalRevenue = 0.0;
  double totalCommission = 0.0;
  int pendingPaymentsCount = 0;
  int upcomingRenewalsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    setState(() => isLoading = true);

    // read agentId from widget.extra if provided
    if (widget.extra != null &&
        (widget.extra as Map<String, dynamic>)['agentId'] != null) {
      agentId = (widget.extra as Map<String, dynamic>)['agentId'];
    } else {
      // If agentId is not passed, fallback to empty string (you may want to fetch current user)
      agentId = "";
    }

    try {
      // 1. get subscriptions for this agent (assumes service method exists)
      // If your service uses a different method name, change it here.
      final subs = await _subscriptionService.getAgentSubscriptions(agentId);

      // 2. For each subscription fetch policy and client (if available)
      List<Map<String, dynamic>> temp = [];
      for (var s in subs) {
        final policyId = s['policyId'];
        Policy? policy;
        try {
          if (policyId != null) {
            policy = await _policyService.getPolicyById(policyId);
          }
        } catch (_) {
          policy = null;
        }

        // Attempt to fetch client data if you have ClientService.getClientById
        Map<String, dynamic>? client;
        try {
          final userId = s['userId'];
          if (userId != null) {
            client = await _clientService.getClientById(userId);
            // expected to return map: { "id":..., "name":..., "email":... }
          }
        } catch (_) {
          client = null;
        }

        temp.add({...s, 'policyDetails': policy, 'clientDetails': client});
      }

      setState(() {
        _records = temp;
      });

      _computeMetrics();
    } catch (e) {
      debugPrint('Failed to load agent data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _computeMetrics() {
    // apply month/year filter when computing lists (0 month means all)
    final filtered = _records.where((rec) {
      if (selectedMonth == 0) return true;
      final date = rec['startDate'] ?? rec['createdAt'] ?? rec['nextDueDate'];
      if (date == null) return true;

      try {
        final dt = _extractDate(date);
        return dt.year == selectedYear && dt.month == selectedMonth;
      } catch (_) {
        return true;
      }
    }).toList();

    // unique clients
    final clientIds = <String>{};
    for (var r in filtered) {
      final uid = r['userId']?.toString();
      if (uid != null && uid.isNotEmpty) clientIds.add(uid);
    }
    totalClients = clientIds.length;

    // total policies sold
    totalPoliciesSold = filtered.length;

    // revenue and commission sums
    double revenue = 0.0;
    double commission = 0.0;
    for (var r in filtered) {
      final Policy? p = r['policyDetails'];
      // price may be string; parse safely
      final price = _parseCurrencyToDouble(p?.price);
      revenue += price;

      // commission might be string amount or percentage (e.g. "10%" or "1500")
      final comm = _parseCommissionToAmount(p?.commission, price);
      commission += comm;
    }
    totalRevenue = revenue;
    totalCommission = commission;

    // pending payments: treat subscription status not equal to "paid" as pending
    pendingPaymentsCount = filtered.where((r) {
      final st = (r['status'] ?? '').toString().toLowerCase();
      return st != 'paid' && st != 'completed';
    }).length;

    // upcoming renewals: nextDueDate within next 30 days
    final now = DateTime.now();
    final thirty = now.add(const Duration(days: 30));
    upcomingRenewalsCount = filtered.where((r) {
      final nextDue = r['nextDueDate'];
      if (nextDue == null) return false;
      try {
        final dt = _extractDate(nextDue);
        return dt.isAfter(now) && dt.isBefore(thirty);
      } catch (_) {
        return false;
      }
    }).length;

    setState(() {});
  }

  // Helper: extract DateTime from dynamic (Firestore Timestamp or DateTime or string)
  DateTime _extractDate(dynamic dateObj) {
    if (dateObj == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (dateObj is DateTime) return dateObj;
    // Firestore Timestamp typically has toDate()
    try {
      if (dateObj.toDate != null) {
        return dateObj.toDate();
      }
    } catch (_) {}
    return DateTime.parse(dateObj.toString());
  }

  // Safely parse price strings like "1200", "1,200", "1200.50", "PKR 1,200"
  double _parseCurrencyToDouble(String? raw) {
    if (raw == null) return 0.0;
    try {
      // remove anything except digits, dot and minus
      final cleaned = raw.replaceAll(RegExp(r'[^0-9\.\-]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  // Convert commission string to amount:
  // - if "10%" treat as percentage of price
  // - otherwise parse as absolute amount
  double _parseCommissionToAmount(String? rawCommission, double price) {
    if (rawCommission == null) return 0.0;
    final r = rawCommission.trim();
    if (r.endsWith('%')) {
      final numPart = r.substring(0, r.length - 1);
      final pct =
          double.tryParse(numPart.replaceAll(RegExp(r'[^0-9\.\-]'), '')) ?? 0.0;
      return price * pct / 100.0;
    } else {
      return _parseCurrencyToDouble(r);
    }
  }

  // UI helpers
  String _formatDate(dynamic dateObj) {
    if (dateObj == null) return "N/A";
    try {
      final dt = _extractDate(dateObj);
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return dateObj.toString();
    }
  }

  String _formatCurrency(double value) {
    if (value == 0.0) return "0";
    try {
      final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
      return formatter.format(value);
    } catch (_) {
      return value.toStringAsFixed(2);
    }
  }

  // Filter UI helpers
  List<DropdownMenuItem<int>> _yearItems() {
    final current = DateTime.now().year;
    return List.generate(5, (i) => current - i).map((y) {
      return DropdownMenuItem(
        value: y,
        child: UpText('$y', style: UpStyle(textFontFamily: 'Poppins')),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _monthItems() {
    final months = <String>[
      'All',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return List.generate(13, (i) {
      return DropdownMenuItem(
        value: i,
        child: UpText(months[i], style: UpStyle(textFontFamily: 'Poppins')),
      );
    });
  }

  // Get filtered lists for sections
  List<Map<String, dynamic>> get _policiesSold {
    return _applyDateFilter(_records);
  }

  List<Map<String, dynamic>> get _pendingPayments {
    return _applyDateFilter(_records).where((r) {
      final st = (r['status'] ?? '').toString().toLowerCase();
      return st != 'active' && st != 'cancelled';
    }).toList();
  }

  List<Map<String, dynamic>> get _upcomingRenewals {
    final now = DateTime.now();
    final thirty = now.add(const Duration(days: 30));
    return _applyDateFilter(_records).where((r) {
      final nextDue = r['nextDueDate'];
      if (nextDue == null) return false;
      try {
        final dt = _extractDate(nextDue);
        return dt.isAfter(now) && dt.isBefore(thirty);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _applyDateFilter(List<Map<String, dynamic>> list) {
    if (selectedMonth == 0) {
      return list.where((r) {
        // if year filter active
        if (selectedYear != 0) {
          try {
            final dt = _extractDate(
              r['startDate'] ?? r['createdAt'] ?? r['nextDueDate'],
            );
            return dt.year == selectedYear;
          } catch (_) {
            return true;
          }
        }
        return true;
      }).toList();
    } else {
      return list.where((r) {
        try {
          final dt = _extractDate(
            r['startDate'] ?? r['createdAt'] ?? r['nextDueDate'],
          );
          return dt.year == selectedYear && dt.month == selectedMonth;
        } catch (_) {
          return true;
        }
      }).toList();
    }
  }

  // UI build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: customAppBar(context, 'Agent Records'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAgentData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top summary heading
                    UpText(
                      'Agent Performance',
                      style: UpStyle(
                        textSize: 20,
                        textFontFamily: 'Sora',
                        textWeight: FontWeight.bold,
                        textColor: const Color(0xFF1B1D28),
                      ),
                    ),
                    const SizedBox(height: 8),
                    UpText(
                      'Overview of client, sales and commission data',
                      style: UpStyle(
                        textSize: 13,
                        textFontFamily: 'Poppins',
                        textColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Summary cards row
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            'Clients',
                            '$totalClients',
                            Icons.people,
                            const Color(0xFF5D45DA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            'Policies Sold',
                            '$totalPoliciesSold',
                            Icons.receipt_long,
                            const Color(0xFF00B894),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            'Revenue',
                            _formatCurrency(totalRevenue),
                            Icons.attach_money,
                            const Color(0xFFFFA726),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            'Commission',
                            _formatCurrency(totalCommission),
                            Icons.monetization_on,
                            const Color(0xFF6C5CE7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Filters
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              UpText(
                                'Year',
                                style: UpStyle(
                                  textFontFamily: 'Poppins',
                                  textSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: selectedYear,
                                items: _yearItems(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    selectedYear = v;
                                    _computeMetrics();
                                  });
                                },
                                underline: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              UpText(
                                'Month',
                                style: UpStyle(
                                  textFontFamily: 'Poppins',
                                  textSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: selectedMonth,
                                items: _monthItems(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    selectedMonth = v;
                                    _computeMetrics();
                                  });
                                },
                                underline: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Refresh
                        IconButton(
                          onPressed: _loadAgentData,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Sections
                    _sectionHeader('Policies Sold (${_policiesSold.length})'),
                    const SizedBox(height: 12),
                    Column(
                      children: _policiesSold
                          .map((r) => _soldItemCard(r))
                          .toList(),
                    ),

                    const SizedBox(height: 18),
                    _sectionHeader(
                      'Pending Payments (${_pendingPayments.length})',
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _pendingPayments
                          .map((r) => _pendingItemCard(r))
                          .toList(),
                    ),

                    const SizedBox(height: 18),
                    _sectionHeader(
                      'Upcoming Renewals (${_upcomingRenewals.length})',
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _upcomingRenewals
                          .map((r) => _renewalItemCard(r))
                          .toList(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UpText(
                title,
                style: UpStyle(
                  textSize: 13,
                  textFontFamily: 'Poppins',
                  textColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              UpText(
                value,
                style: UpStyle(
                  textSize: 18,
                  textWeight: FontWeight.bold,
                  textFontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UpText(
          title,
          style: UpStyle(
            textSize: 16,
            textFontFamily: 'Sora',
            textWeight: FontWeight.bold,
          ),
        ),
        // small stats right
        UpText(
          'Updated: ${DateFormat('d MMM yyyy').format(DateTime.now())}',
          style: UpStyle(
            textSize: 12,
            textFontFamily: 'Poppins',
            textColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _soldItemCard(Map<String, dynamic> r) {
    final Policy? p = r['policyDetails'];
    final client = r['clientDetails'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // small avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF5D45DA),
            child: UpText(
              (client != null &&
                      client['name'] != null &&
                      client['name'].toString().isNotEmpty)
                  ? client['name'].toString().substring(0, 1).toUpperCase()
                  : (p?.name.isNotEmpty == true
                        ? p!.name.substring(0, 1).toUpperCase()
                        : 'A'),
              style: UpStyle(
                textColor: Colors.white,
                textFontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UpText(
                  p?.name ?? 'Unknown Policy',
                  style: UpStyle(
                    textSize: 15,
                    textFontFamily: 'Sora',
                    textWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                UpText(
                  client != null
                      ? (client['name'] ?? 'Unknown Client')
                      : 'Unknown Client',
                  style: UpStyle(
                    textSize: 13,
                    textFontFamily: 'Poppins',
                    textColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    UpText(
                      'Sold: ',
                      style: UpStyle(
                        textSize: 13,
                        textFontFamily: 'Poppins',
                        textColor: Colors.grey,
                      ),
                    ),
                    UpText(
                      _formatDate(r['startDate'] ?? r['createdAt']),
                      style: UpStyle(textSize: 13, textFontFamily: 'Poppins'),
                    ),
                    const SizedBox(width: 12),
                    UpText(
                      'Price: ',
                      style: UpStyle(
                        textSize: 13,
                        textFontFamily: 'Poppins',
                        textColor: Colors.grey,
                      ),
                    ),
                    UpText(
                      p?.price ?? 'N/A',
                      style: UpStyle(textSize: 13, textFontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // commission and more
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UpText(
                'Commission',
                style: UpStyle(
                  textSize: 12,
                  textFontFamily: 'Poppins',
                  textColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              UpText(
                _formatCurrency(
                  _parseCommissionToAmount(
                    p?.commission,
                    _parseCurrencyToDouble(p?.price),
                  ),
                ),
                style: UpStyle(
                  textSize: 14,
                  textFontFamily: 'Poppins',
                  textWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () {
                  ServiceManager<UpNavigationService>().navigateToNamed(
                    Routes.clientSubscriptionsPage,
                    extra: {'clientId': r['userId']},
                  );
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pendingItemCard(Map<String, dynamic> r) {
    final Policy? p = r['policyDetails'];
    final client = r['clientDetails'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.orange.withOpacity(0.16),
            child: const Icon(Icons.hourglass_top, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UpText(
                  p?.name ?? 'Unknown Policy',
                  style: UpStyle(
                    textSize: 14,
                    textFontFamily: 'Sora',
                    textWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                UpText(
                  client != null
                      ? (client['name'] ?? 'Unknown Client')
                      : 'Unknown Client',
                  style: UpStyle(
                    textSize: 13,
                    textFontFamily: 'Poppins',
                    textColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    UpText(
                      'Due: ',
                      style: UpStyle(
                        textSize: 13,
                        textFontFamily: 'Poppins',
                        textColor: Colors.grey,
                      ),
                    ),
                    UpText(
                      _formatDate(r['nextDueDate']),
                      style: UpStyle(textSize: 13, textFontFamily: 'Poppins'),
                    ),
                    const SizedBox(width: 12),
                    UpText(
                      'Amount: ',
                      style: UpStyle(
                        textSize: 13,
                        textFontFamily: 'Poppins',
                        textColor: Colors.grey,
                      ),
                    ),
                    UpText(
                      p?.price ?? 'N/A',
                      style: UpStyle(textSize: 13, textFontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // logic to resend invoice or remind client
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Reminder sent')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: UpText(
              'Remind',
              style: UpStyle(
                textFontFamily: 'Poppins',
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renewalItemCard(Map<String, dynamic> r) {
    final Policy? p = r['policyDetails'];
    final client = r['clientDetails'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.12),
            child: const Icon(Icons.calendar_today, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UpText(
                  p?.name ?? 'Unknown Policy',
                  style: UpStyle(
                    textSize: 14,
                    textFontFamily: 'Sora',
                    textWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                UpText(
                  client != null
                      ? (client['name'] ?? 'Unknown Client')
                      : 'Unknown Client',
                  style: UpStyle(
                    textSize: 13,
                    textFontFamily: 'Poppins',
                    textColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    UpText(
                      'Renewal: ',
                      style: UpStyle(
                        textSize: 13,
                        textFontFamily: 'Poppins',
                        textColor: Colors.grey,
                      ),
                    ),
                    UpText(
                      _formatDate(r['nextDueDate']),
                      style: UpStyle(textFontFamily: 'Poppins', textSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick action: create invoice
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice created (mock)')),
              );
            },
            icon: const Icon(Icons.receipt_long, size: 16),
            label: UpText(
              'Invoice',
              style: UpStyle(
                textFontFamily: 'Poppins',
                textColor: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D45DA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
