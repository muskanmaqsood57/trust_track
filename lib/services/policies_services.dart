import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trust_track/models/policy.dart';

class PolicyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Policy?> getPolicyById(String policyId) async {
    try {
      final doc = await _firestore.collection('policies').doc(policyId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Policy(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: data['price'].toString(),
        paymentCycle: data['paymentCycle'] ?? '',
        commission: data['commission'] ?? '',
      );
    } catch (e) {
      throw Exception('Failed to get policy: $e');
    }
  }

  Future<List<Policy>> getPolicies() async {
    try {
      // Fetch all documents from the "Policies" collection
      QuerySnapshot snapshot = await _firestore.collection("policies").get();

      // Convert each document to a Policy model
      return snapshot.docs.map((doc) {
        return Policy.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch policies: $e");
    }
  }

  Future<void> addPolicy(
    String name,
    String description,
    String price,
    String paymentCycle,
    String commission,
  ) async {
    try {
      await _firestore.collection("policies").add({
        "name": name,
        "description": description,
        "price": price,
        "paymentCycle": paymentCycle,
        "commission": commission,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add policy: $e");
    }
  }
}
