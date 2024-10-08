import 'dart:io';

import 'package:cal_cam/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Result extends StatelessWidget {
  final File image ;
  final String predicted ;
  final  String calories ;
  const Result({super.key, required this.image, required this.predicted, required this.calories});

  @override
  Widget build(BuildContext context) {
    // Extract the numerical part from the calories string
    int caloriesValue = int.parse(calories.replaceAll(RegExp(r'[^0-9]'), ''));

    // Calculate percentage based on a maximum of 600 calories
    double percentage = (caloriesValue / 600).clamp(0.0, 1.0);
    print(calories);
    return  SafeArea(
      child: Scaffold(
      
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
                child:Stack(
              children: [
                Image.file(image,width: double.infinity,fit: BoxFit.fill,),
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon:                 const Icon(Icons.arrow_back,size: 30,color: Colors.black,)
                )
              ],
            )),
            Expanded(
                flex: 2,
                child: Container(
             child: Column(
               children: [
                 SizedBox(height: 50,),
      
                 SizedBox(height: 50,),
                  Text(calories,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                 Text(predicted,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),)
               ],
             ),
            ))
          ],
        ),
      ),
    );
  }
}
