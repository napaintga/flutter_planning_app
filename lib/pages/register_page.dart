import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cryptography/cryptography.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'package:base_x/base_x.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:solana/solana.dart';



class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();
  bool _isValid = false;
  String _errorMessage = '';
  String _recoveryPhrase = '';

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




  Future<String> _generateKey(String password) async {
    final algorithm = Ed25519();

    final keyPair = await algorithm.newKeyPair();
    final privateKey = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    const PREFIX = "ed25519:";

    final base58Codec = BaseXCodec('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');

    final privateKeyBase58 = PREFIX + base58Codec.encode(Uint8List.fromList(privateKey));
    final publicKeyBase58 = PREFIX + base58Codec.encode(Uint8List.fromList(publicKey.bytes));

    print("Private Key: $privateKeyBase58");
    print("Public Key: $publicKeyBase58");

    const int iterationCount = 65536;
    const int keyLength = 32;
    const int saltLength = 16;
    const int ivLength = 12;

    final salt = Uint8List.fromList(List<int>.generate(saltLength, (i) => Random.secure().nextInt(256)));

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterationCount,
      bits: keyLength * 8,
    );

    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final passwordHash = await secretKey.extractBytes();

    print('Salt: ${base64.encode(salt)}');
    print('Password Hash: ${base64.encode(passwordHash)}');
    final nonce = Uint8List.fromList(List<int>.generate(ivLength, (i) => Random.secure().nextInt(256)));
    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(true, pc.AEADParameters(pc.KeyParameter(Uint8List.fromList(passwordHash)), 128, nonce, Uint8List(0)));

    final plaintext = utf8.encode(privateKeyBase58);
    final encryptedData = cipher.process(Uint8List.fromList(plaintext));

    final tag = cipher.mac;

    final encryptedBytes = Uint8List.fromList(nonce + salt + encryptedData + tag);

    final encodedData = base64Encode(encryptedBytes);

    print('Зашифровані дані: $encodedData');

    return encodedData;
  }

  String _generateRecoveryPhrase() {
    final random = Random.secure();
    const wordList = [
      'apple', 'orange', 'banana', 'grape', 'lemon', 'mango', 'peach', 'pear',
      'plum', 'berry', 'melon', 'kiwi', 'cherry', 'fig', 'date', 'apricot',
      'lime', 'coconut', 'blueberry', 'raspberry'
    ];
    List<String> phrase = [];
    for (int i = 0; i < 12; i++) {
      phrase.add(wordList[random.nextInt(wordList.length)]);
    }
    return phrase.join(' ');
  }

  Future<void> _saveKeys(String encryptedPrivateKey ) async {


    // String encodedData = await _generateKey('mytestpassword');
    // String? decryptedKey = await _decryptKey(encodedData, 'mytestpassword');
    //
    // if (decryptedKey != null) {
    //   print('Розшифрований ключ: $decryptedKey');
    // } else {
    //   print('Не вдалося розшифрувати ключ.');
    // }
    final directory = await getApplicationDocumentsDirectory();
    final username = _usernamecontroller.text;

    final filePath = '${directory.path}/${username}_keys.json';
    final file = File(filePath);
    print(filePath);
    final jsonContent = jsonEncode({
      "username": _usernamecontroller.text,
      "privateKey": encryptedPrivateKey,
      "recoveryPhrase": _recoveryPhrase,
      "pas":_passwordcontroller.text,
    });

    await file.writeAsString(jsonContent);
  }




  void _showRecoveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recovery Phrase"),
        content: Text(
          "Please save the following recovery phrase in a safe place:\n\n$_recoveryPhrase",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
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
                      hintText: "USER NAME",
                      icon: const Icon(Icons.mail_outline),
                      controller: _usernamecontroller,
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
// Assuming you have a method to generate or retrieve the publicKey

                MyButton(
                text: "REGISTER",
                onPressed: () async { // Mark the callback as async
                  setState(() {
                    _isValid = _validatePassword(
                        _passwordcontroller.text,
                        _confirmpasswordcontroller.text
                    );
                  });

                  if (_isValid) {
                    _recoveryPhrase = _generateRecoveryPhrase();
                    _showRecoveryDialog(context);
                    final password = _passwordcontroller.text;

                    try {
                      final privateKey = await _generateKey(password);

                      _saveKeys(privateKey);

                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Keys and recovery phrase saved successfully!")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to save keys: $e")),
                      );
                    }
                  }
                },
              ),


                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login now",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

