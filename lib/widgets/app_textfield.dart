import 'package:flutter/material.dart';
import 'package:user_info/constants/app_colors.dart';

Widget appTextField(
    {String? title,
    TextEditingController? controller,
    TextInputType? keyboardType}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title!,
          style: const TextStyle(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
              fontSize: 13.0),
        ),
      ),
      // const SizedBox(
      //   height: 2.0,
      // ),
       SizedBox(height: 45.0,
        width: 373,
        child: TextFormField(
          controller: controller,

          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 3.0,horizontal: 12.0),
              focusedBorder:OutlineInputBorder( borderSide: BorderSide(width: 1, color: AppColors.appButtonColor)) ,
              enabledBorder: OutlineInputBorder( borderSide: BorderSide(width: 1, color: AppColors.textFieldOutline)),
         //border: OutlineInputBorder(borderSide:BorderSide(width: 1, color: AppColors.appButtonColor) )
          ),
          keyboardType: keyboardType,
        ),
      ),
    ],
  );
}
