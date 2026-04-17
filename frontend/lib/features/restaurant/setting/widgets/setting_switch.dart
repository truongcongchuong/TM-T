import 'package:flutter/material.dart';

class SettingSwitch extends StatefulWidget {
  final String label;

  const SettingSwitch({super.key, required this.label});

  @override
  State<SettingSwitch> createState() => _SettingSwitch();
}

class _SettingSwitch extends State<SettingSwitch> {
  bool value = true;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(widget.label),
      value: value,
      activeColor: Colors.red,
      onChanged: (v) => setState(() => value = v),
    );
  }
}