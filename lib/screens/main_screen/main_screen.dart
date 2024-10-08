import 'package:cal_cam/app_colors.dart';
import 'package:cal_cam/screens/home_screen.dart';
import 'package:cal_cam/screens/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile_screen.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openCamera(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Handle the image file here
      print('Image path: ${image.path}');
      await uploadImage(File(image.path),context);
    }
  }

  Future<void> uploadImage(File imageFile, BuildContext context) async {    final SharedPreferences prefs = await SharedPreferences.getInstance();


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
        int goal= prefs.getInt("goal") as int;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => Result(
                    image: imageFile, predicted: predictedLabel, calories: caloriesInfo)));
        FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update(
            {
              "consumed":int.tryParse(caloriesInfo.substring(0,3)),
              "remaining":goal - (int.parse(caloriesInfo.substring(0,3)))
            });
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
    return Scaffold(
      body: Center(
        child: _selectedIndex == 0 ? HomeScreen() : ProfilePage(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          _openCamera(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: AppColors.buttonColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 2,
        shape: const CircularNotchedRectangle(),
        notchMargin: 15.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: [
                IconButton(
                  icon: _selectedIndex == 1
                      ? Image.asset(
                          "images/material-symbols_home-outline-rounded(1).png")
                      : Image.asset(
                          "images/material-symbols_home-outline-rounded(2).png"),
                  onPressed: () {
                    _onItemTapped(0);
                  },
                ),
                Text(
                  "Home",
                  style: TextStyle(
                    color: _selectedIndex == 1
                        ? Colors.grey
                        : AppColors.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(),
            Column(
              children: [
                IconButton(
                  icon: _selectedIndex == 0
                      ? Image.asset(
                          "images/Group(1).png",
                        )
                      : Image.asset(
                          "images/iconamoon_profile-fill.png",
                        ),
                  onPressed: () {
                    _onItemTapped(1);
                  },
                ),
                Text(
                  "Profile",
                  style: TextStyle(
                    color: _selectedIndex == 0
                        ? Colors.grey
                        : AppColors.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
