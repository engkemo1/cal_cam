import 'dart:io';

import 'package:cal_cam/screens/result.dart';
import 'package:cal_cam/screens/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
  final ImagePicker _picker = ImagePicker();



   Future<void> _openCamera(BuildContext context) async {
     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
     if (image != null) {
       // Handle the image file here
       print('Image path: ${image.path}');
       await uploadImage(File(image.path),context);
     }
   }

   Future<void> uploadImage(File imageFile, BuildContext context) async {
     final dio = Dio();

     try {
       // Prepare the image file as MultipartFile
       String fileName = imageFile.path.split('/').last;
       FormData formData = FormData.fromMap({
         'image': await MultipartFile.fromFile(
           imageFile.path,
           filename: fileName,
         ),
       });

       // Send the POST request to the server
       Response response = await dio.post(
         'http://10.0.2.2:8000/predict', // Change to match your setup
         data: formData,
       );

       print(response);

       // Handle the response
       if (response.statusCode == 200) {
         final responseBody = response.data;
         String predictedLabel = responseBody['predicted_label'];
         String caloriesInfo = responseBody['calories_info'];
         Navigator.push(
             context,
             MaterialPageRoute(
                 builder: (_) => Result(
                     image: imageFile, predicted: predictedLabel, calories: caloriesInfo)));
         print('Predicted Label: $predictedLabel');
         print('Calories Info: $caloriesInfo');
       } else {
         print('Error: ${response.statusCode}');
       }
     } catch (e) {
       print('Failed to upload image: $e');
     }
   }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              return ListView(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("images/Group.png"),
                      fit: BoxFit.cover,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Hi, ${snapshot.data["userName"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                          const Text(
                            "Let's check your Calorie",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 25),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xff74AC95),
                                      borderRadius: BorderRadius.circular(18)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Goal",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22),
                                      ),
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            snapshot.data["goal"].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          ),
                                          Text("    Cal"),
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xffD2E8E0),
                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Expanded(
                                              flex: 3,
                                              child: Text(
                                                "Remaining",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 4,
                                                child: Container(
                                                  height: double.infinity,
                                                  decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              "images/Vector(1).png"),
                                                          fit: BoxFit.cover)),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          snapshot.data[
                                                              "remaining"].toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 22),
                                                        ),
                                                        Text("    Cal"),
                                                      ],
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                        child: Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xffD2E8E0),
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Consumed",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                snapshot.data["consumed"].toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22),
                                              ),
                                              const Text("    Cal"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ))
                                  ],
                                ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: (){
                            _openCamera(context);
                          },
                          child: CustomTextField(

                            controller: TextEditingController(),
                            suffixIcon:Image.asset("images/Vector(5).png",color: Colors.black,),
                            prefixIcon: Image.asset("images/Vector(2).png",color: Colors.black,),
                            hintText: "Add Breakfast",
                            hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            isEnable: false,
                          ),
                        ),
                        SizedBox(height: 5,),
                    InkWell(
                        onTap: (){
                          _openCamera(context);
                        },                      child: CustomTextField(

                          controller: TextEditingController(),
                          suffixIcon:Image.asset("images/Vector(5).png",color: Colors.black,),
                          prefixIcon: Image.asset("images/Vector(3).png",color: Colors.black,),
                          hintText: "Add Lunch",
                          hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          isEnable: false,
                        )),
                        SizedBox(height: 5,),

                    InkWell(
                        onTap: (){
                          _openCamera(context);
                        },                      child: CustomTextField(

                          controller: TextEditingController(),
                          suffixIcon:Image.asset("images/Vector(5).png",color: Colors.black,),
                          prefixIcon: Image.asset("images/Group(3).png",color: Colors.black,),
                          hintText: "Add Dinner",
                          hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          isEnable: false,
                        )),
                        SizedBox(height: 5,),

                    InkWell(
                        onTap: (){
                          _openCamera(context);
                        },                      child:CustomTextField(

                          controller: TextEditingController(),
                          suffixIcon:Image.asset("images/Vector(5).png",color: Colors.black,),
                          prefixIcon: Image.asset("images/Vector(4).png",color: Colors.black,),
                          hintText: "Add Dinner",
                          hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          isEnable: false,
                        )),
                      ],
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}
