import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class StatusCapsule extends StatelessWidget {
  const StatusCapsule({super.key, required this.label, this.color = PhiusTokens.green});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

void showToast(BuildContext context, String message, {bool isError = false}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 24,
      right: 24,
      bottom: 28,
      child: SafeArea(
        child: Center(child: StatusCapsule(label: message, color: isError ? PhiusTokens.primaryDark : PhiusTokens.green)),
      ),
    ),
  );
  overlay.insert(entry);
  Timer(Duration(milliseconds: isError ? 5200 : 3200), entry.remove);
}
