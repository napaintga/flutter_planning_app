import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:pointycastle/export.dart' as pc;
import '../components/my_button.dart';
import '../constants.dart';
import 'package:proecfxd/service/contract_service.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  final ContractService contractServiceTask;

  const RegisterPage({
    Key? key,
    required this.onTap,
    required this.contractServiceTask,
  }) : super(key: key);

  @override
  ConsumerState<RegisterPage >createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();
  bool _isValid = false;
  String _errorMessage = '';
  String _recoveryPhrase = '';
  String _ethereumAddress = '';

  Future<bool> _register(String userName, String userAddress) async {
    final contractService = ref.read(ContractService.provider);

    try {
      await contractService.registerUser(userName, userAddress);
      return true;
    } catch (e) {
      print("Error registering user: $e");
      throw Exception("Registration failed: $e");
    }
  }

  bool _validatePassword(String password, String confirmpassword,String username) {
    _errorMessage = '';
    if (username.isEmpty){
      _errorMessage += " Enter a username.";

    } else if (password.isEmpty) {
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
    final credentials = await _generateEthereumCredentials(password);
    final address = credentials.address;
    _ethereumAddress = address.hex;

    print("Ethereum Address: $address");
    print("Private Key: ${credentials.privateKey}");
    final encryptedPrivateKey = await _encryptPrivateKey(password, credentials);

    return encryptedPrivateKey;
  }

  Future<EthPrivateKey> _generateEthereumCredentials(String password) async {
    final rpcUrl = Constants.RPC_URL;
    final ethClient = Web3Client(rpcUrl, http.Client());
    final credentials = await ethClient.credentialsFromPrivateKey(Constants.PRIVATE_KEY);
    return credentials;
  }


  Future<String> _encryptPrivateKey(String password, EthPrivateKey privateKey) async {
    final privateKeyBytes = privateKey.privateKey;
    const int iterationCount = 65536;
    const int keyLength = 32;
    const int saltLength = 16;
    const int ivLength = 12;

    final salt = Uint8List.fromList(List<int>.generate(saltLength, (i) => Random.secure().nextInt(256)));

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

    final nonce = Uint8List.fromList(List<int>.generate(ivLength, (i) => Random.secure().nextInt(256)));

    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(true, pc.AEADParameters(pc.KeyParameter(Uint8List.fromList(passwordHash)), 128, nonce, Uint8List(0)));

    final encryptedData = cipher.process(Uint8List.fromList(privateKeyBytes));
    final tag = cipher.mac;
    final encryptedBytes = Uint8List.fromList(nonce + salt + encryptedData + tag);
    final encodedData = base64Encode(encryptedBytes);
    print('Encrypted Data: $encodedData');

    return encodedData;
  }

  Future<EthPrivateKey> _decryptPrivateKey(String password, String encryptedData) async {
    final encryptedBytes = base64Decode(encryptedData); // Декодування Base64
    const int saltLength = 16; // Довжина солі
    const int ivLength = 12; // Довжина nonce
    const int tagLength = 16; // Довжина MAC

    // Розділення даних
    final nonce = encryptedBytes.sublist(0, ivLength);
    final salt = encryptedBytes.sublist(ivLength, ivLength + saltLength);
    final encryptedPayload = encryptedBytes.sublist(ivLength + saltLength, encryptedBytes.length - tagLength);

    const int iterationCount = 65536;
    const int keyLength = 32;

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
  }




  Future<void> _saveKeys(String encryptedPrivateKey) async {
    final directory = await getApplicationDocumentsDirectory();
    final username = _usernamecontroller.text;

    final filePath = '${directory.path}/${username}_keys.json';
    final file = File(filePath);
    final jsonContent = jsonEncode({
      "username": _usernamecontroller.text,
      "privateKey": encryptedPrivateKey,
      "ethereumAddress": _ethereumAddress,
      "recoveryPhrase": _recoveryPhrase,
      "password": _passwordcontroller.text,
    });
    await file.writeAsString(jsonContent);

    final filePath_key = '${directory.path}/${username}_key.json';
    final file_key = File(filePath_key);
    final jsonContent_key = jsonEncode({
      "privateKey": encryptedPrivateKey,
    });

    await file_key.writeAsString(jsonContent_key);
  }

  String _generateRecoveryPhrase() {
    const phrases = [
      "apple", "banana", "grape", "orange", "peach", "kiwi", "cherry", "melon", "pear", "plum"
    ];
    final random = Random();
    final recoveryPhrase = List.generate(12, (_) => phrases[random.nextInt(phrases.length)]).join(' ');
    return recoveryPhrase;
  }

  void _showRecoveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recovery Phrase"),
        content: Text(
          "Please save the following recovery phrase and Ethereum address in a safe place:\n\n"
              "$_recoveryPhrase\n\n"
              "Ethereum Address: $_ethereumAddress",
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
                    TextField(
                      controller: _usernamecontroller,
                      decoration: InputDecoration(
                        labelText: 'USER NAME',
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordcontroller,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _confirmpasswordcontroller,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CONFIRM PASSWORD',
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
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
                      text: "REGISTER",
                      onPressed: () async {
                        setState(() {
                          _isValid = _validatePassword(
                            _passwordcontroller.text,
                            _confirmpasswordcontroller.text,
                              _usernamecontroller.text,
                          );
                        });

                        if (_isValid) {
                          final password = _passwordcontroller.text;


                          try {
                            final encryptedPrivateKey = await _generateKey(password);
                            final isRegistered = await _register(
                              _usernamecontroller.text,
                              _ethereumAddress,
                            );
                            print(isRegistered);
                            if (isRegistered) {
                              await _saveKeys(encryptedPrivateKey);
                              _recoveryPhrase = _generateRecoveryPhrase();
                              _showRecoveryDialog(context);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:const Text("User already registered."),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color.fromRGBO(
                                    136, 13, 13, 1.0),
                              ),
                            );
                          }
                        }
                      }
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already a member? "),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login now",
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
