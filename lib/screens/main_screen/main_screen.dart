import 'package:cal_cam/app_colors.dart';
import 'package:cal_cam/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../logic/cal_cam_logic.dart';
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

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Handle the image file here
      print('Image path: ${image.path}');
      await uploadImage(File(image.path));
    }
  }

  Future<void> uploadImage(File imageFile) async {
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
        'http://127.0.0.1:8000/predict',
        data: formData,
      );

      // Handle the response
      if (response.statusCode == 200) {
        final responseBody = response.data;
        String predictedLabel = responseBody['predicted_label'];
        String caloriesInfo = responseBody['calories_info'];
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
        onPressed: _openCamera,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: AppColors.buttonColor,
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
