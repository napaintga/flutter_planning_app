import 'dart:convert' ;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proecfxd/components/my_button.dart';
import './home_page.dart';
import '../components/my_textfield.dart';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;
import 'package:cryptography/cryptography.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  bool _isLogin = false;
  String _errorMessageLogin = '';

  Future<bool> login(String username, String password) async {
    setState(() {
      _errorMessageLogin = '';
    });

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessageLogin = "Enter a username and password";
      });
      return false;
    }

    final isValid = await readAndValidatePassword(username, password);

    if (!isValid) {
      setState(() {
        _errorMessageLogin = "Invalid password";
      });
      print(_errorMessageLogin);
      return false;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }

    return true;
  }

  Future<bool> readAndValidatePassword(String username, String enteredPassword) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${username}_keys.json';
    final file = File(filePath);

    if (!await file.exists()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("No key file for this user."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }

    String fileContent = await file.readAsString();
    final decodedJson = jsonDecode(fileContent);

    final encrypted = decodedJson['privateKey'];
    print("Encrypted Password: $encrypted");

    // Decode Base64 string
    Uint8List encryptedMessage = base64Decode(encrypted);
    print("Raw Base64 Password: $encryptedMessage");

    // Attempt to decrypt the private key
    String? decryptedKey = await _decryptKey(encrypted, enteredPassword);

    if (decryptedKey != null) {
      print('Decrypted key: $decryptedKey');
      return true; // Password is valid
    } else {
      return false; // Invalid password
    }
  }

  Future<String?> _decryptKey(String encodedData, String password) async {
    try {
      // Decode data from Base64
      final encryptedBytes = base64Decode(encodedData);

      // Extract nonce, salt, encrypted data, and tag
      final nonce = encryptedBytes.sublist(0, 12); // first 12 bytes
      final salt = encryptedBytes.sublist(12, 28); // next 16 bytes
      final encryptedData = encryptedBytes.sublist(28, encryptedBytes.length - 16); // data between nonce and tag
      final tag = encryptedBytes.sublist(encryptedBytes.length - 16); // last 16 bytes

      // Parameters for PBKDF2
      const int iterationCount = 65536;
      const int keyLength = 32;

      // Initialize PBKDF2 with HMAC SHA256
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterationCount,
        bits: keyLength * 8, // Bit length
      );

      // Hash password using the salt
      final secretKey = await pbkdf2.deriveKey(
        secretKey: SecretKey(utf8.encode(password)),
        nonce: salt, // salt used as nonce
      );

      // Get hash bytes
      final passwordHash = await secretKey.extractBytes();

      // Initialize AES GCM for decryption
      final cipher = pc.GCMBlockCipher(pc.AESEngine())
        ..init(false, pc.AEADParameters(pc.KeyParameter(Uint8List.fromList(passwordHash)), 128, nonce, Uint8List(0)));

      // Decrypt data
      final decryptedData = cipher.process(Uint8List.fromList(encryptedData));

      // Convert bytes back to string
      final decryptedKey = utf8.decode(decryptedData);

      return decryptedKey; // Return decrypted private key
    } catch (e) {
      print('Decryption failed: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Please sign in to continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 50),
                    MyTextfield(
                      hintText: "USER NAME",
                      icon: const Icon(Icons.mail_outline),
                      controller: _usernamecontroller,
                      obsecureText: false,
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(height: 25),
                    MyTextfield(
                      hintText: "PASSWORD",
                      icon: const Icon(Icons.lock_outline),
                      controller: _passwordcontroller,
                      obsecureText: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!_isLogin && _errorMessageLogin.isNotEmpty)
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
                            _isLogin ? '' : _errorMessageLogin,
                            style: TextStyle(
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    MyButton(
                      text: "LOGIN",
                      onPressed: () async {
                        // Asynchronous call outside of setState
                        final isLogin = await login(_usernamecontroller.text, _passwordcontroller.text);

                        setState(() {
                          _isLogin = isLogin;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Not a member? "),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Register now",
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
