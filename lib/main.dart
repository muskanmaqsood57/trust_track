import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trust_track/app.dart';
import 'package:trust_track/locator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
