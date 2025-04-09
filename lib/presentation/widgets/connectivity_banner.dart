import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final String message;
  final Color color;
  
  const ConnectivityBanner({
    Key? key,
    required this.message,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Icon(
                color == Colors.red ? Icons.wifi_off : Icons.wifi,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
