import 'package:flutter/material.dart';
import 'package:trust_track/services/client_service.dart';
import 'package:trust_track/widget/appbar.dart';

class ClientManagementPage extends StatefulWidget {
  final Object? extra;
  const ClientManagementPage({super.key, this.extra});

  @override
  State<ClientManagementPage> createState() => _ClientManagementPageState();
}

class _ClientManagementPageState extends State<ClientManagementPage> {
  final ClientService _clientService = ClientService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _clients = [];
  String userName = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.extra is Map<String, dynamic>) {
      userName = (widget.extra as Map<String, dynamic>)["userName"] ?? "";
    }
    await _loadClients();
    setState(() {
      _isLoading = false;
    });
  }

  _loadClients() async {
    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error loading clients: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Client Management", userName),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
          ? const Center(child: Text("No clients found."))
          : ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 93, 69, 218),
                    ),
                    title: Text(client["name"] ?? "No Name"),
                    subtitle: Text(client["email"] ?? "No Email"),
                  ),
                );
              },
            ),
    );
  }
}
