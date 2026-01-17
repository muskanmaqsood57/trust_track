import 'package:flutter/material.dart';
import 'package:flutter_up/locator.dart';
import 'package:flutter_up/services/up_navigation.dart';
import 'package:trust_track/constants.dart';
import 'package:trust_track/services/client_service.dart';
import 'package:trust_track/widget/appbar.dart';

class ClientManagementPage extends StatefulWidget {
  const ClientManagementPage({super.key});

  @override
  State<ClientManagementPage> createState() => _ClientManagementPageState();
}

class _ClientManagementPageState extends State<ClientManagementPage> {
  final ClientService _clientService = ClientService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _clients = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _clientService.getAgentClients();
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading clients: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedClients = [..._clients]
      ..sort((a, b) => (a["name"] ?? "").compareTo(b["name"] ?? ""));

    final filteredClients = sortedClients.where((client) {
      final name = (client["name"] ?? "").toString().toLowerCase();
      final email = (client["email"] ?? "").toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      appBar: customAppBar(context, "Client Management"),
      backgroundColor: const Color(0xFFF8F9FB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Page Heading =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Your Clients",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sora',
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Manage and view all clients linked to your account",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Search Bar =====
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ===== List of Clients =====
                Expanded(
                  child: filteredClients.isEmpty
                      ? const Center(
                          child: Text(
                            "No clients found.",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = filteredClients[index];
                            return GestureDetector(
                              onTap: () {
                                ServiceManager<UpNavigationService>()
                                    .navigateToNamed(
                                      Routes.clientSubscriptionsPage,
                                      extra: {'clientId': client["id"]},
                                    );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: const Color(0xFF5D45DA),
                                      child: Text(
                                        (client["name"] ?? "C")
                                            .toString()
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      client["name"] ?? "No Name",
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Sora',
                                        color: Color(0xFF2E2E2E),
                                      ),
                                    ),
                                    subtitle: Text(
                                      client["email"] ?? "No Email",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF6B6B6B),
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
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
