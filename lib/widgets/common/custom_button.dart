import 'package:flutter/material.dart';

/// Bouton personnalisé réutilisable avec deux variantes
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = color ?? Theme.of(context).primaryColor;

    // Contenu du bouton (texte ou chargement)
    Widget buttonChild = isLoading
        ? SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined ? buttonColor : Colors.white,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    // Style commun
    final ButtonStyle elevatedStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: Colors.white,
      minimumSize: Size(width ?? double.infinity, height ?? 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final ButtonStyle outlinedStyle = OutlinedButton.styleFrom(
      foregroundColor: buttonColor,
      minimumSize: Size(width ?? double.infinity, height ?? 50),
      side: BorderSide(color: buttonColor, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return isOutlined
        ? OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: outlinedStyle,
      child: buttonChild,
    )
        : ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: elevatedStyle,
      child: buttonChild,
    );
  }
}