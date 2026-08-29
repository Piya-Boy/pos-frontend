import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class PrimaryButton extends _AppButton {
  const PrimaryButton({super.key, required super.onPressed, super.child, super.label})
      : super(backgroundColor: PhiusTokens.primary, foregroundColor: Colors.white, shadow: PhiusTokens.shadowSm);
}

class SecondaryButton extends _AppButton {
  const SecondaryButton({super.key, required super.onPressed, super.child, super.label})
      : super(backgroundColor: PhiusTokens.green, foregroundColor: Colors.white);
}

class OutlineButton extends _AppButton {
  const OutlineButton({super.key, required super.onPressed, super.child, super.label})
      : super(foregroundColor: PhiusTokens.primary, borderColor: PhiusTokens.primary);
}

class GhostButton extends _AppButton {
  const GhostButton({super.key, required super.onPressed, super.child, super.label})
      : super(backgroundColor: PhiusTokens.surface, foregroundColor: PhiusTokens.ink, borderColor: PhiusTokens.border);
}

class _AppButton extends StatelessWidget {
  const _AppButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.shadow,
  }) : assert(child != null || label != null);

  final VoidCallback? onPressed;
  final Widget? child;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: shadow),
    child: SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor ?? Colors.transparent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        child: child ?? Text(label!),
      ),
    ),
  );
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({super.key, required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: PhiusTokens.surface,
        side: const BorderSide(color: PhiusTokens.border),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: child,
    ),
  );
}
