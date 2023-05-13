import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    ),
  );
}
