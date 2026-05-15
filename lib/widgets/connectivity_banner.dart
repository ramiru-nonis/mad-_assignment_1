import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final isOffline = results.isNotEmpty &&
            results.every((r) => r == ConnectivityResult.none);

        return Column(
          children: [
            if (isOffline)
              Material(
                color: Colors.red.shade700,
                child: const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are offline — showing cached data',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
