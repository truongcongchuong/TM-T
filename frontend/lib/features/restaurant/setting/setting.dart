import 'package:flutter/material.dart';
import 'widgets/context.dart';

class RestaurantSettingsScreen extends StatelessWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: isDesktop
          ? Row(
              children: [
                Expanded(child: Context()),
              ],
            )
          : Context(),
    );
  }
}
