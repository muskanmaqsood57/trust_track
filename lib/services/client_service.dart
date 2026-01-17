import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trust_track/services/auth_service.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .where("role", isEqualTo: "client")
          .get();

      return snapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch clients: $e");
    }
  }

  Future<Map<String, dynamic>?> getClientById(String clientId) async {
    try {
      final doc = await _firestore.collection("users").doc(clientId).get();

      if (!doc.exists) return null;

      return {"id": doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      throw Exception("Failed to fetch client: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAgentClients() async {
    try {
      var userData = await _auth.getUserData() ?? {};
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .where("role", isEqualTo: "client")
          .where("invited_user_id", isEqualTo: userData['user_id'])
          .get();

      return snapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch clients: $e");
    }
  }
}
