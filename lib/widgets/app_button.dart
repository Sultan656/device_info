import 'package:flutter/material.dart';
import 'package:user_info/constants/app_colors.dart';

Widget appButton({VoidCallback? onTap,String? title}){
 return GestureDetector(
   onTap: onTap,
   child: Container(
     height: 40,
     width: 360,
     decoration: BoxDecoration(
       color: AppColors.appButtonColor,
       borderRadius: BorderRadius.circular(1.0),

     ),
     child: Center(child: Text(title!,style: TextStyle(color: AppColors.appBgColor,fontWeight: FontWeight.w500,fontSize: 12.0),),),
   ),
 ) ;
}