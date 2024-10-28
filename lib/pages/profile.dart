import 'package:flutter/material.dart';
import 'package:solana/solana.dart';

import '../components/bottom_appbar.dart';


class SolanaWallet extends StatefulWidget {
  @override
  _SolanaWalletState createState() => _SolanaWalletState();
}

class _SolanaWalletState extends State<SolanaWallet> {
  final String _address = '7hnVQnGNTy37Bf3q1mQFNvHJ2QhiiFZcwhAdXrYrZCh5';
  double? _balance;

  @override
  void initState() {
    super.initState();
    _getBalance();
  }

  Future<void> _getBalance() async {
    final connection = RpcClient('https://api.devnet.solana.com');

    final pubkey = Ed25519HDPublicKey.fromBase58(_address);

    try {
      final balance = await connection.getBalance(pubkey.toString());
      print("dfg ${balance.value}");
      setState(() {
        _balance = balance.value.toDouble()/1e9 ;
      });
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _balance != null
              ? Text('Balance: $_balance SOL')
              : CircularProgressIndicator(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _getBalance,
            child: Text('Refresh Balance'),
          ),
        ],
      ),
    ),
      bottomNavigationBar:  MyBottomAppBar(),
    );
  }
}
