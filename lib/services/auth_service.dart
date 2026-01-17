// ignore_for_file: avoid_print

import 'dart:math';

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
    String? invitedUserId,
  }) async {
    try {
      // 1️⃣ Create user in Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = cred.user!.uid;

      // 2️⃣ Generate custom 6-character user_id like W73F9P
      String generatedUserId = await _generateUniqueUserCode();

      // 3️⃣ Prepare user data for Firestore
      Map<String, dynamic> userData = {
        "uid": uid,
        "user_id": generatedUserId,
        "name": name,
        "email": email,
        "contactNumber": contactNumber,
        "cnic": cnic,
        "role": role,
        "invited_user_id": invitedUserId ?? "",
        "joinedDate": DateTime.now(),
      };

      // 4️⃣ Save in Firestore
      await _firestore.collection("users").doc(uid).set(userData);

      print("✅ Sign up successful: $userData");
      return userData;
    } on FirebaseAuthException catch (e) {
      return {"error": e.message};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  Future<String> _generateUniqueUserCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    String code;

    while (true) {
      code = List.generate(
        6,
        (_) => chars[random.nextInt(chars.length)],
      ).join();

      final snapshot = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) break; // unique found
    }

    return code;
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
      _cachedRole = null; // reset cached role
      print("✅ Logout successful, role cache cleared");
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

  Future<String?> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.uid;
  }
}
