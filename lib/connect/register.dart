// import 'dart:convert';
// import 'package:cryptography/cryptography.dart';
// import 'package:bs58/bs58.dart' as bs;
//
// Future<void> generateKeys() async {
//   final algorithm = Ed25519();
//
//   // Generate a key pair
//   final keyPair = await algorithm.newKeyPair();
//   final privateKey = await keyPair.extractPrivateKeyBytes();
//   final publicKey = await keyPair.extractPublicKey();
//
//   const PREFIX = "ed25519:";
//
//   // Base58 encode the keys
//   final privateKeyBase58 = PREFIX + bs.base58Encode(privateKey);
//   final publicKeyBase58 = PREFIX + base58(publicKey.bytes);
//
//   print("Private Key: $privateKeyBase58");
//   print("Public Key: $publicKeyBase58");
// }
//
// void main() {
//   generateKeys();
// }
