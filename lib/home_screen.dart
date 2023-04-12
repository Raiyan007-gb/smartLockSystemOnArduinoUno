import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'auth_gate.dart';
import 'gradient_button.dart';
import 'gradient_button_with_icon.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final Widget child;

  const HomeScreen({Key? key, required this.user, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purple, Colors.red],
            tileMode: TileMode.mirror,
            stops: [0.0, 1.0],
          ).createShader(bounds),
          child: const Text(
            'Smart Lock System',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Sign Out'),
                        onPressed: () {
                          FlutterFireUIAuth.signOut();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ), // IconButton
        ],
        backgroundColor: Colors
            .transparent, // Set the AppBar background color to transparent
        elevation: 0, // Remove the AppBar elevation
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/1.png'),
              fit: BoxFit
                  .cover, // Set the image fit to cover the entire AppBar background
            ),
          ),
        ),
      ),
      body: Container(
        // Place as the child widget of a scaffold
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CircleAvatar(
              //     radius: 30, backgroundImage: NetworkImage(user.photoURL!)),
              // SizedBox(height: 10),
              // Text(
              //   user.uid,
              //   style: const TextStyle(
              //     fontSize: 15,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 10),
              Text(
                user.email!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Expanded(
                child: BluetoothPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  late BluetoothConnection connection;
  bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Place as the child widget of a scaffold
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    backgroundGradient: const LinearGradient(
                      colors: [Colors.purple, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    buttonText: '   CONNECT    ',
                    onPressed: _connectToBluetooth,
                  ),
                  const SizedBox(width: 20),
                  GradientButton(
                      backgroundGradient: const LinearGradient(
                        colors: [Colors.purple, Colors.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      buttonText: 'DISCONNECT',
                      onPressed: _disconnectBluetooth),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButtonIcon(
                    backgroundGradient: const LinearGradient(
                      colors: [Colors.orange, Colors.yellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onPressed: () {
                      if (isConnected) {
                        _unlock();
                      } else {
                        null;
                      }
                    },
                    child: const Icon(Icons.lock_open_rounded),
                  ),
                  const SizedBox(width: 20),
                  GradientButtonIcon(
                    backgroundGradient: const LinearGradient(
                      colors: [Colors.orange, Colors.yellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onPressed: () {
                      if (isConnected) {
                        _lock();
                      } else {
                        null;
                      }
                    },
                    child: const Icon(Icons.lock_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                      backgroundGradient: const LinearGradient(
                        colors: [Color(0xff4338CA), Color(0xff6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      buttonText: 'MEETING MODE ON',
                      onPressed: () {
                        if (isConnected) {
                          _mettingOn();
                        } else {
                          null;
                        }
                      }),
                  const SizedBox(width: 20),
                  GradientButton(
                      backgroundGradient: const LinearGradient(
                        colors: [Color(0xff4338CA), Color(0xff6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      buttonText: 'MEETING MODE OFF',
                      onPressed: () {
                        if (isConnected) {
                          _mettingOff();
                        } else {
                          null;
                        }
                      }),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                      backgroundGradient: const LinearGradient(
                        colors: [Color(0xff4338CA), Color(0xff6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      buttonText: 'ADD FINGERPRINT',
                      onPressed: () {
                        if (isConnected) {
                          _addFingerprint();
                        } else {
                          null;
                        }
                      }),
                  const SizedBox(width: 20),
                  GradientButton(
                      backgroundGradient: const LinearGradient(
                        colors: [Color(0xff4338CA), Color(0xff6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      buttonText: '       ERASE FING      ',
                      onPressed: () {
                        if (isConnected) {
                          _eraseFingerprint(context);
                        } else {
                          null;
                        }
                      }),
                ],
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: isConnected ? _8 : null,
              //   child: const Text('8'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _connectToBluetooth() async {
    if (isConnected) {
      const snackBar = SnackBar(
        content: Text('DEVICE ALREADY CONNECTED'),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
      Timer(const Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
      return;
    }

    List<BluetoothDevice> devices = [];

    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    BluetoothDevice device = devices.firstWhere(
      (device) => device.name == 'HC-05',
      orElse: () => const BluetoothDevice(name: '', address: ''),
    );

    BluetoothConnection newConnection =
        await BluetoothConnection.toAddress(device.address);

    setState(() {
      connection = newConnection;
      isConnected = true;
    });
    const snackBar = SnackBar(
      content: Text('DEVICE IS CONNECTED!'),
    );

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
    Timer(const Duration(milliseconds: 1000), () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }

  void _disconnectBluetooth() async {
    if (isConnected) {
      await connection.finish();
      setState(() {
        isConnected = false;
      });
      const snackBar = SnackBar(
        content: Text('DEVICE IS DISCONNECTED!'),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
      Timer(const Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
  }

  void _lock() async {
    if (isConnected) {
      connection.output.add(Uint8List.fromList("1".codeUnits));
      await connection.output.allSent;
      const snackBar = SnackBar(
        content: Text('DOOR IS LOCKED'),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
      Timer(const Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
  }

  void _unlock() async {
    if (isConnected) {
      connection.output.add(Uint8List.fromList("0".codeUnits));
      await connection.output.allSent;
      const snackBar = SnackBar(
        content: Text('DOOR IS UNLOCKED'),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
      Timer(const Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
  }

  void _mettingOn() async {
    if (isConnected) {
      String message = "67895";
      List<int> bytes = utf8.encode(message);
      connection.output.add(Uint8List.fromList(bytes));
      await connection.output.allSent;
      const snackBar = SnackBar(
        content: Text('MEETING MODE ON'),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
      Timer(const Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
  }

  void _eraseFingerprint(BuildContext context) async {
    // Check if the user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not authenticated, show the sign in screen
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AuthGate()));
      return;
    }

    // User is authenticated, show the password dialog
    TextEditingController passwordController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Enter your password',
              style: TextStyle(
                  color: Colors.white)), // set the text color to white
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate the password
                String password = passwordController.text.trim();
                AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!, password: password);
                try {
                  await user.reauthenticateWithCredential(credential);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(true);
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message!)),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // If the password was entered correctly, erase the fingerprints
    if (result == true) {
      if (isConnected) {
        String message = "-1";
        List<int> bytes = utf8.encode(message);
        connection.output.add(Uint8List.fromList(bytes));
        await connection.output.allSent;
        const snackBar = SnackBar(
          content: Text('All the registered fingerprints are erased!!'),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Hide the snackbar after 0.5 seconds
        Timer(const Duration(milliseconds: 1000), () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        });
      }
    }
  }

  void _mettingOff() async {
    if (isConnected) {
      String message = "23456";
      List<int> bytes = utf8.encode(message);
      connection.output.add(Uint8List.fromList(bytes));
      await connection.output.allSent;
      const snackBar = SnackBar(
        content: Text('MEETING MODE OFF'),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
      Timer(const Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
  }

  void _addFingerprint() async {
    if (isConnected) {
      String message = "879065";
      List<int> bytes = utf8.encode(message);
      connection.output.add(Uint8List.fromList(bytes));
      await connection.output.allSent;
      const snackBar = SnackBar(
        content: Text('PLACE YOUR FINGERPRINT ON THE SENSOR'),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

// Hide the snackbar after 0.5 seconds
      Timer(const Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      connection.dispose();
      isConnected = false;
    }
    super.dispose();
  }
}
