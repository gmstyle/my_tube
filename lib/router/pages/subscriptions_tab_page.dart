import 'package:flutter/material.dart';

class SubscriptionsTabPAge extends Page {
  const SubscriptionsTabPAge({Key? key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return const Scaffold(
            body: Center(
              child: Text('Subscriptions Tab'),
            ),
          );
        });
  }
}
