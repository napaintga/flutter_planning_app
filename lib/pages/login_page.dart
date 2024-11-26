import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proecfxd/components/my_button.dart';
import 'package:web3dart/credentials.dart';
import './home_page.dart';
import '../components/my_textfield.dart';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;
import 'package:cryptography/cryptography.dart' as cryptography;

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
  final TextEditingController _privateKeyController = TextEditingController(); // Новий контролер

  bool _isLogin = false;
  String _errorMessageLogin = '';

  Future<bool> login(String username, String password, String? privateKey) async {
    setState(() {
      _errorMessageLogin = '';
    });

    if (username.isEmpty || (password.isEmpty && privateKey == null)) {
      setState(() {
        _errorMessageLogin = "Enter a username and either password or private key";
      });
      return false;
    }

    if (privateKey != null) {
      final isValid = await validatePrivateKey(username, privateKey);
      if (!isValid) {
        setState(() {
          _errorMessageLogin = "Invalid private key";
        });
        return false;
      }
    } else {
      final isValid = await readAndValidatePassword(username, password);
      if (!isValid) {
        setState(() {
          _errorMessageLogin = "Invalid password";
        });
        return false;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );

    return true;
  }

  Future<bool> validatePrivateKey(String username, String privateKey) async {
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
    final storedPrivateKey = decodedJson['privateKey'];

    if (storedPrivateKey == privateKey) {
      return true;
    }

    return false;
  }

  Future<bool> readAndValidatePassword(String username, String enteredPassword) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${username}_key.json';
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
    print("Encrypted32 Private Key: $encrypted");
    Uint8List encryptedMessage = base64Decode(encrypted);
    print("Raw Base64 Private Key: $encryptedMessage");
    final decryptedKey = await _decryptKey(enteredPassword,encrypted );
    if (decryptedKey != null) { // Виконуємо перевірку, чи ключ існує
      print('Decrypted key: ${decryptedKey.privateKey}');
      return true;
    } else {
      return false;
    }
  }

  Future<EthPrivateKey?> _decryptKey(String password, String encryptedData) async {
    try{
      final encryptedBytes = base64Decode(encryptedData);
      const int saltLength = 16;
      const int ivLength = 12;
      const int tagLength = 16;
      final nonce = encryptedBytes.sublist(0, ivLength);
      final salt = encryptedBytes.sublist(ivLength, ivLength + saltLength);
      final encryptedPayload = encryptedBytes.sublist(ivLength + saltLength, encryptedBytes.length - tagLength);

      const int iterationCount = 65536;
      const int keyLength = 32;

      // Генерація ключа з пароля
      final pbkdf2 = cryptography.Pbkdf2(
        macAlgorithm: cryptography.Hmac.sha256(),
        iterations: iterationCount,
        bits: keyLength * 8,
      );

      final secretKey = await pbkdf2.deriveKey(
        secretKey: cryptography.SecretKey(utf8.encode(password)),
        nonce: salt,
      );

      final passwordHash = await secretKey.extractBytes();

      final cipher = pc.GCMBlockCipher(pc.AESEngine())
        ..init(false, pc.AEADParameters(pc.KeyParameter(Uint8List.fromList(passwordHash)), 128, nonce, Uint8List(0)));
      final decryptedBytes = cipher.process(Uint8List.fromList(encryptedPayload));

      final privateKey = EthPrivateKey(Uint8List.fromList(decryptedBytes));
      print("Decrypted Private Key: ${privateKey.privateKey}");
      return privateKey;
    } catch (e) {
      print('Decryption error: $e');
      return null;}

  }

  void _showPrivateKeyDialog() {
    final TextEditingController _keyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Restore Access"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: "Enter Private Key",
                  hintText: "Private Key",
                  icon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final privateKey = _keyController.text;
                if (privateKey.isNotEmpty) {
                  final isValid = await validatePrivateKey(_usernamecontroller.text, privateKey);
                  if (isValid) {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Invalid Private Key"),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              child: Text("Restore"),
            ),
          ],
        );
      },
    );
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
                        final isLogin = await login(
                          _usernamecontroller.text,
                          _passwordcontroller.text,
                          _privateKeyController.text.isNotEmpty ? _privateKeyController.text : null,
                        );

                        setState(() {
                          _isLogin = isLogin;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _showPrivateKeyDialog,
                          child: Text(
                            "Restore Access",
                            style: TextStyle(
                              color: Color.fromRGBO(73, 102, 151, 1.0),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                              fontWeight: FontWeight.w500,
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
