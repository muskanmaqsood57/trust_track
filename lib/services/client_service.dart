import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
