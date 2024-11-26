
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proecfxd/service/contract_service.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import '../components/bottom_appbar.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;

class TestPage extends ConsumerStatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  final TextEditingController _des = TextEditingController();
  String _privateKey = '';
  String _publicKey = '';
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<EthPrivateKey> _generateEthereumCredentials() async {
    final rpcUrl = Constants.RPC_URL;
    final ethClient = Web3Client(rpcUrl, http.Client());
    final credentials = await ethClient.credentialsFromPrivateKey(Constants.PRIVATE_KEY);
    return credentials;
  }

  Future<void> _fetchUserDetails() async {
    final credentials = await _generateEthereumCredentials();
    final address = credentials.address;

    final rpcUrl = Constants.RPC_URL;
    final ethClient = Web3Client(rpcUrl, http.Client());

    final balanceInWei = await ethClient.getBalance(address);
    final balanceInEther = balanceInWei.getInEther;

    setState(() {
      _privateKey = credentials.privateKey.hashCode.toString();
      _publicKey = credentials.address.toString();
      _balance = balanceInEther.toDouble();
    });
  }

  void _incrementCounter() {
    ref.read(ContractService.provider).incrementCount();
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(ContractService.provider).count;

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Color.fromRGBO(219, 226, 252, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('User Information:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 16),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Public Key: $_publicKey', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      Text('Balance: $_balance ETH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              const Text('You have pushed the button this many times:', style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(height: 8),
              Text('$counter', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(
                  11, 32, 61, 1.0),)),

              SizedBox(height: 20),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        backgroundColor: Color.fromRGBO(219, 226, 252, 1.0),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: MyBottomAppBar(onPressed: () {}),
    );
  }
}
