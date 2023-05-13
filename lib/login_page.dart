import 'package:flutter/material.dart';
import 'package:day13/Animation/FadeAnimation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loginButtonEnabled = false;
  bool _isLoading = false;

  Future signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-email':
        case 'unknown':
          QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              customAsset: 'assets/images/error2.gif',
              titleColor: Colors.white,
              text:
                  'Make sure you have entered your correct username and password',
              textColor: Colors.white,
              backgroundColor: Color(0xFF1A2E28),
              confirmBtnText: 'Close',
              confirmBtnColor: Color(0xFFCC9238));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _emailController.addListener(() {
      setState(() {
        _loginButtonEnabled = _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      });
    });
    _passwordController.addListener(() {
      setState(() {
        _loginButtonEnabled = _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF55796C),
              Color(0xFF1A2E28),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FadeAnimation(
                          1.3,
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Image.asset(
                                    'assets/images/gardenGuruLogo.png',
                                    scale: 2,
                                  ),
                                ),
                                Text('GardenGuru',
                                    style: GoogleFonts.pacifico(
                                        color: Colors.white, fontSize: 30)),
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 50,
                      ),
                      FadeAnimation(
                          1.5,
                          Text(
                            "Login",
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          1.7,
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1A2E28),
                                    blurRadius: 90,
                                    offset: Offset(0, 0),
                                  )
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextField(
                                    style: TextStyle(color: Colors.white),
                                    cursorColor: Colors.white,
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Username",
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: TextField(
                                    style: TextStyle(color: Colors.white),
                                    cursorColor: Colors.white,
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          1.9,
                          GestureDetector(
                            onTap: () {
                              _loginButtonEnabled ? signIn() : null;
                            },
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(horizontal: 60),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: _loginButtonEnabled
                                    ? Color(0xFF004A35)
                                    : Color(0xFF334D45),
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          2,
                          Center(
                              child: Text(
                            "Create Account",
                            style: TextStyle(color: Color(0xFFFFFFFF)),
                          ))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _isLoading
            ? Positioned.fill(
                child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ))
            : Container(),
      ],
    );
  }
}
