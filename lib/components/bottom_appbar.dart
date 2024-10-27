

import 'package:flutter/material.dart';

import '../auth/register_or_login.dart';
import 'package:http/http.dart' as http;

Future<void> sendTransaction() async {
  final response = await http.post(
    Uri.parse('https://your-backend-url.com/sendTransaction'),
    body: {
      'accountId': 'your-account-id',
      'contractId': 'your-contract-id',
      'method': 'your-method-name',
      'args': {'key': 'value'},
    },
  );

  if (response.statusCode == 200) {
    print('Transaction successful');
  } else {
    print('Transaction failed');
  }
}

class MyBottomAppBar extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      height: 70,
      color:theme.primaryColor ,
      child: Row(
        children: [
          IconButton(
            tooltip: 'exit_to_app',
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginOrRegister()),
              );
            },
          ),
          IconButton(
            tooltip: 'cached',
            icon: const Icon(Icons.cached_outlined),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'theme',
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => sendTransaction(),
          ),
        ],
      ),
    );
  }
}