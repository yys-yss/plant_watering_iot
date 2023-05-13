import 'package:day13/firebase_sensor_display.dart';
import 'package:day13/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                color: Colors.white,
              );
            }
            if (snapshot.hasData) {
              return FirebaseSensorDisplay();
            } else {
              return LoginPage();
            }
          }),
    );
  }
}
