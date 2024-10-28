

import 'package:flutter/material.dart';

import '../auth/register_or_login.dart';
import '../pages/home_page.dart';
import '../pages/profile.dart';


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
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SolanaWallet()),
              );
            },
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.task_alt_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),

        ],
      ),
    );
  }
}