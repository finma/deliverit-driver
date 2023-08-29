import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/config/app_color.dart';
import '/config/app_format.dart';

class DateTimePickerCubit extends Cubit<DateTime?> {
  DateTimePickerCubit() : super(null);

  Future<DateTime?> selectDateTime(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      helpText: 'Pilih Tanggal Lahir',
      initialDate: state ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      emit(DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      ));
    }

    return selectedDate;
  }
}

class CustomDateTimePickerFormField extends StatelessWidget {
  const CustomDateTimePickerFormField({
    Key? key,
    this.borderRadius = 12,
    this.controller,
    this.hintText,
    this.iconAsset,
    this.paddingVertical = 20,
    this.paddingHorizontal = 16,
    this.validator,
  }) : super(key: key);

  final String? hintText;
  final String? iconAsset;
  final double paddingVertical;
  final double paddingHorizontal;
  final double borderRadius;
  final TextEditingController? controller;
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context) {
    final dateTimePickerCubit = context.read<DateTimePickerCubit>();

    return BlocBuilder<DateTimePickerCubit, DateTime?>(
      builder: (context, selectedDateTime) {
        return TextFormField(
          readOnly: true,
          controller: controller,
          onTap: () async {
            final DateTime? selectDate =
                await dateTimePickerCubit.selectDateTime(context);

            selectDate != null
                ? controller?.text = AppFormat.date(selectDate.toString())
                : controller?.text = '';
          },
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            isDense: true,
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
              child: Image.asset(
                iconAsset!,
                width: 24,
                height: 24,
              ),
            ),
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
          validator: (value) {
            final selectedDate = context.read<DateTimePickerCubit>().state;
            return validator?.call(selectedDate);
          },
        );
      },
    );
  }
}
