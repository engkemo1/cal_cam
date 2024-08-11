import 'package:cal_cam/app_colors.dart';
import 'package:cal_cam/screens/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../validators.dart';
import 'login_screen.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _picker = ImagePicker();
  File? _image;
  final _nameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();


  Future<void> _updateImage() async {
    if (_image == null) return;

    // Upload image to Firebase Storage
    String userId = FirebaseAuth.instance.currentUser!
        .uid; // Replace with actual user ID
    final ref = _storage.ref().child('profile_images/$userId.jpg');
    await ref.putFile(_image!);

    // Get the image URL
    final url = await ref.getDownloadURL();

    // Update Firestore with the new image URL
    await _firestore.collection('users').doc(userId).update({
      'image': url,
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _updateImage();
    }
  }
  Future<void> _updateProfile() async {
    // Get current user ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Validate inputs if needed
    if (userNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty) {
      // Show error message or perform validation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Update Firestore document
    try {
      await _firestore.collection('users').doc(userId).update({
        'userName': userNameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
      });

      // Optionally update image URL if a new image was picked
      if (_image != null) {
        await _updateImage();
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users")
            .doc(userId)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            userNameController.text = snapshot.data["userName"];
            emailController.text = snapshot.data["email"];
            phoneNumberController.text = snapshot.data["phoneNumber"];
          }
          return ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.asset("images/Rectangle 6048.png"),
                      Positioned(
                        top: 40,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(child: Icon(Icons.arrow_back_ios_sharp), onTap: () {
                                Navigator.pop(context);
                              },),
                              SizedBox(width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,),
                              Text("Edit profile", style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 23),)
                            ],),
                        ),
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : snapshot.data?['image'] != ""
                                ? NetworkImage(snapshot.data?['image'], scale: 0.9)
                                : AssetImage("images/Mask group.png",),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.green),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: userNameController,
                          labelText: "UserName",
                          validator: (v) => Validators.validateName(v, context),
                          hintText: "Sara",
                        ),
                        CustomTextField(
                          controller: emailController,
                          labelText: "Email",
                          validator: (v) => Validators.validateEmail(v, context),
                          hintText: "Sara123@gmail.com",
                        ),
                        CustomTextField(
                          controller: phoneNumberController,
                          labelText: "Phone Number",
                          prefixIcon: const Text(
                              "+966", style: TextStyle(fontWeight: FontWeight.w600)),
                          validator: (v) =>
                              Validators.validatePhoneNumber(v, context),
                          hintText: "542121456",
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text("Save",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w600),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
