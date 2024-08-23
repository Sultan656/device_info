import 'package:flutter/material.dart';
import 'package:user_info/constants/app_colors.dart';

Widget appButton({VoidCallback? onTap,String? title,Color? bgColor}){
 return GestureDetector(
   onTap: onTap,
   child: Container(
     height: 40,
     width: 373,
     decoration: BoxDecoration(
       color: bgColor ?? AppColors.appButtonColor,
       borderRadius: BorderRadius.circular(4.0),

     ),
     child: Center(child: Text(title!,style: const TextStyle(color: AppColors.appBgColor,fontWeight: FontWeight.w500,fontSize: 12.0),),),
   ),
 ) ;
}