import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '/config/app_color.dart';

class PasswordCubit extends Cubit<bool> {
  PasswordCubit() : super(true);

  void togglePasswordVisibility() {
    emit(!state);
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    this.borderRadius = 12,
    this.controller,
    this.hintText,
    this.iconAsset,
    this.icon,
    this.initialValue,
    this.isDense = true,
    this.isDisabled = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.paddingVertical = 20,
    this.paddingHorizontal = 16,
    this.validator,
  }) : super(key: key);

  final String? hintText;
  final String? iconAsset;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool isDense;
  final bool isPassword;
  final bool isDisabled;
  final int maxLines;
  final double paddingVertical;
  final double paddingHorizontal;
  final double borderRadius;
  final Icon? icon;
  final Function(String)? onChanged;
  final Function()? onTap;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordCubit(),
      child: BlocBuilder<PasswordCubit, bool>(
        builder: (context, isPasswordHidden) {
          return TextFormField(
            controller: controller,
            obscureText: isPassword ? isPasswordHidden : false,
            initialValue: initialValue,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            onChanged: onChanged,
            readOnly: isDisabled,
            onTap: onTap,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              isDense: isDense,
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.symmetric(
                vertical: paddingVertical,
                horizontal: paddingHorizontal,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: icon ??
                    Image.asset(
                      iconAsset!,
                      width: 24,
                      height: 24,
                    ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        context
                            .read<PasswordCubit>()
                            .togglePasswordVisibility();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(color: AppColor.secondary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(color: AppColor.secondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
