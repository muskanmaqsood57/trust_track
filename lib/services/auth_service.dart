// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static String? _cachedRole;

  Future<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
    required String contactNumber,
    required String cnic,
    required String role, // "agent" or "client"
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = cred.user!.uid;

      // Save extra data in Firestore
      Map<String, dynamic> userData = {
        "uid": uid,
        "name": name,
        "email": email,
        "contactNumber": contactNumber,
        "cnic": cnic,
        "role": role,
        "joinedDate": DateTime.now(),
      };

      await _firestore.collection("users").doc(uid).set(userData);

      print("✅ Sign up successful: $userData");
      return userData; // return user profile instead of null
    } on FirebaseAuthException catch (e) {
      return {"error": e.message};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = cred.user!.uid;

      // Fetch Firestore profile
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(uid)
          .get();

      if (userDoc.exists) {
        print("✅ Login successful, UID: $uid, Data: ${userDoc.data()}");
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("⚠️ No profile found in Firestore for UID $uid");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      return {"error": e.message};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("⚠️ Logout error: $e");
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<String?> getUserRole() async {
    if (_cachedRole != null) {
      return _cachedRole; // no delay, instant response
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    _cachedRole = doc.data()?["role"];
    return _cachedRole;
  }
}
