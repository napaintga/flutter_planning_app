import 'dart:io';
import 'dart:convert';
import 'dart:math'; // For Random.secure()
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:path_provider/path_provider.dart';

import '../components/my_textfield.dart';
import '../components/my_button.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();

  bool _isValid = false;
  String _errorMessage = '';

  // Password validation method
  bool _validatePassword(String password, String confirmpassword) {
    _errorMessage = '';

    if (password.isEmpty) {
      _errorMessage += " Enter a password.";
    } else if (password.length < 8) {
      _errorMessage += ' Password must be longer than 8 characters.';
    } else if (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage += ' Uppercase letter is missing.';
    } else if (!password.contains(RegExp(r'[a-z]'))) {
      _errorMessage += ' Lowercase letter is missing.';
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage += ' Digit is missing.';
    } else if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _errorMessage += ' Special character is missing.';
    } else if (password != confirmpassword) {
      _errorMessage += ' Those passwords didn’t match. Try again.';
    }

    return _errorMessage.isEmpty;
  }

  // RSA Key generation method
  pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey> _generateKeyPair() {
    final keyParams = pc.RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);
    final secureRandom = pc.FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));

    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(keyParams, secureRandom));

    final pair = keyGen.generateKeyPair();
    return pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey>(
      pair.publicKey as pc.RSAPublicKey,
      pair.privateKey as pc.RSAPrivateKey,
    );
  }

  Future<void> _saveKeys(String publicKey, String privateKey, String username) async {
    final directory = await getApplicationDocumentsDirectory();

    final publicKeyFile = File('${directory.path}/$username-public_key.txt');
    final privateKeyFile = File('${directory.path}/$username-private_key.txt');

    await publicKeyFile.writeAsString(publicKey);
    await privateKeyFile.writeAsString(privateKey);

    print("Keys saved successfully to ${directory.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 50),
                    MyTextfield(
                      hintText: "EMAIL",
                      icon: const Icon(Icons.mail_outline),
                      controller: _emailcontroller,
                      obsecureText: false,
                    ),
                    const SizedBox(height: 15),
                    MyTextfield(
                      hintText: "PASSWORD",
                      icon: const Icon(Icons.lock_outline),
                      controller: _passwordcontroller,
                      obsecureText: true,
                    ),
                    const SizedBox(height: 15),
                    MyTextfield(
                      hintText: "CONFIRM PASSWORD",
                      icon: const Icon(Icons.lock_outline),
                      controller: _confirmpasswordcontroller,
                      obsecureText: true,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!_isValid && _errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, top: 2),
                            child: Icon(
                              Icons.error,
                              color: Colors.red.shade900,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _isValid ? '' : ' $_errorMessage',
                            style: TextStyle(
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    MyButton(
                      text: " REGISTER",
                      onPressed: () {
                        setState(() {
                          _isValid = _validatePassword(
                              _passwordcontroller.text, _confirmpasswordcontroller.text);

                          if (_isValid) {
                            final keyPair = _generateKeyPair();

                            final publicKey = keyPair.publicKey.toString();
                            final privateKey = keyPair.privateKey.toString();

                            _saveKeys(publicKey, privateKey, _emailcontroller.text.split('@')[0])
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Keys generated and saved successfully!")),
                              );
                            }).catchError((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to save keys: $e")),
                              );
                            });
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(73, 102, 151, 1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
