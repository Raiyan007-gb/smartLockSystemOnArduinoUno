import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providerConfigs: const [
                EmailProviderConfiguration(),
                GoogleProviderConfiguration(
                  clientId:
                      '776670623415-utehvau2pju6css2e5psfsagf937qtk0.apps.googleusercontent.com',
                ),
              ],
              headerBuilder: (context, constraints, _) {
                return CircleAvatar(
                  radius: 65,
                  child: ClipOval(
                    child: Image.network(
                      'https://plus.unsplash.com/premium_photo-1674582743901-7e438e0e5ea0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=747&q=80',
                      width: 130, // set the width and height here
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      action == AuthAction.signIn
                          ? 'Smart Lock System - Sign In'
                          : 'Smart Lock System - Sign Up',
                    ));
              },
              footerBuilder: (context, action) {
                return const Text(
                  'By signing in, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                );
              },
            );
          }
          return HomeScreen(
            user: snapshot.data!,
            child: const SizedBox(),
          );
        });
  }
}
