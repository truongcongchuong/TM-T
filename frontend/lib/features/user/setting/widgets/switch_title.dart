import 'package:flutter/material.dart';

class SwitchTile extends StatefulWidget {
  final IconData icon;
  final String title;

  const SwitchTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  State<SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  bool value = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(widget.icon, color: Colors.red),
        title: Text(widget.title),
        value: value,
        onChanged: (v) {
          setState(() => value = v);
        },
      ),
    );
  }
}
