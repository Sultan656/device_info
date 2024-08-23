
import 'package:flutter/material.dart';
import 'package:user_info/constants/app_colors.dart';

Widget appTextField({
  String? title,
  TextEditingController? controller,
  TextInputType? keyboardType,
  FocusNode? focusNode,
  Function(String)? onFieldSubmitted,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title!,
          style: const TextStyle(
            color: AppColors.blackColor,
            fontWeight: FontWeight.w500,
            fontSize: 13.0,
          ),
        ),
      ),
      SizedBox(
        height: 45.0,
        width: 373,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: AppColors.appButtonColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: AppColors.textFieldOutline),
            ),
          ),
        ),
      ),
    ],
  );
}