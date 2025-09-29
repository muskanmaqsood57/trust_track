import 'package:cloud_firestore/cloud_firestore.dart';

class Agent {
  final String id; // Firestore document ID (same as auth UID if you align them)
  final String name;
  final String email;
  final String contactNumber;
  final String password;
  final DateTime joinedDate;

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.password,
    required this.joinedDate,
  });

  // From Firestore document
  factory Agent.fromFirestore(Map<String, dynamic> data, String docId) {
    return Agent(
      id: docId,
      name: data['Name'] ?? '',
      email: data['Email'] ?? '',
      contactNumber: data['ContactNumber'] ?? '',
      password: data['Password'] ?? '',
      joinedDate: (data['JoinedDate'] as Timestamp).toDate(),
    );
  }

  // To Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "Name": name,
      "Email": email,
      "ContactNumber": contactNumber,
      "Password": password,
      "JoinedDate": joinedDate,
    };
  }
}
