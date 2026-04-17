import 'package:flutter/material.dart';
import '../../core/theme/neumorphic_colors.dart';
import '../../core/utils/neumorphic_style.dart';

class NeumorphicButton extends StatefulWidget {
  final String text;
  final IconData? icon; // 👈 NUEVO (opcional)
  final VoidCallback onTap;
  final NeumorphicColors colors;

  const NeumorphicButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.colors,
    this.icon,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          splashColor: widget.colors.primary.withOpacity(0.15),
          hoverColor: widget.colors.primary.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration:
                _pressed
                    ? NeumorphicStyle.inset(widget.colors)
                    : NeumorphicStyle.elevated(widget.colors),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 22, color: widget.colors.primary),
                  const SizedBox(width: 12),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.colors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
