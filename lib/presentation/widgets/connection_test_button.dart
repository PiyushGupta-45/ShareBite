import 'package:flutter/material.dart';
import 'package:food_donation_app/core/constants/api_constants.dart';
import 'package:food_donation_app/core/utils/connectivity_checker.dart';

class ConnectionTestButton extends StatelessWidget {
  const ConnectionTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
        final status = await ConnectivityChecker.getConnectionStatus(baseUrl);
        
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Connection Test'),
              content: Text(status),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      icon: const Icon(Icons.network_check, size: 16),
      label: const Text('Test Connection'),
    );
  }
}

