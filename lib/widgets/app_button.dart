import 'package:flutter/material.dart';
import 'package:user_info/constants/app_colors.dart';

Widget appButton({VoidCallback? onTap}){
 return GestureDetector(
   onTap: onTap,
   child: Container(
     height: 40,
     width: 373,
     decoration: BoxDecoration(
       color: AppColors.appButtonColor,
       borderRadius: BorderRadius.circular(1.0),

     ),
     child: Center(child: Text("",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12.0),),),
   ),
 ) ;
}