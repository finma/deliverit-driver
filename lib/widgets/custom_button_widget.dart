import 'package:flutter/material.dart';

import '/config/app_color.dart';

enum ButtonType { primary, secondary, outline }

class ButtonCustom extends StatelessWidget {
  const ButtonCustom({
    Key? key,
    required this.label,
    required this.onTap,
    this.isExpanded = true,
    this.type = ButtonType.primary,
    this.icon,
    this.isDisabled = false,
    this.isLoading = false,
  }) : super(key: key);

  final String label;
  final VoidCallback onTap;
  final bool isExpanded;
  final ButtonType type;
  final Icon? icon;
  final bool isDisabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isDisabled
        ? Colors.grey
        : type == ButtonType.primary
            ? AppColor.primary
            : type == ButtonType.secondary
                ? Colors.white
                : Colors.transparent;
    Color borderColor =
        type == ButtonType.outline ? AppColor.primary : Colors.transparent;
    Color textColor =
        type == ButtonType.primary ? Colors.white : AppColor.primary;

    return Material(
      borderRadius: BorderRadius.circular(15),
      color: backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: isDisabled ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            color: Colors.transparent,
          ),
          width: isExpanded ? double.infinity : null,
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: 36,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: isLoading,
                child: Row(
                  children: [
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: textColor,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Visibility(
                visible: icon != null,
                child: Row(
                  children: [
                    icon ?? const SizedBox(),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
