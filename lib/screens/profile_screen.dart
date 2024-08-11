import 'package:cal_cam/app_colors.dart';
import 'package:cal_cam/screens/edit_profle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  File? _image;
  final _nameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String? name;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Assuming you have a userId, fetch data from Firestore
    String userId = 'USER_ID'; // Replace with actual user ID
    var userData = await _firestore.collection('users').doc(userId).get();
    if (userData.exists) {
      setState(() {
        _nameController.text = userData.data()?['name'] ?? '';
        // Load user image URL if needed
      });
    }
  }

  Future<void> _showNameUpdateDialog(BuildContext context) async {
    // Create a TextEditingController for the name input
    final _nameController = TextEditingController();

    // Show the dialog
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    _updateName(value);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                _updateName(_nameController.text);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _updateName(String name) async {
    // Assuming you have a userId
    String userId = FirebaseAuth.instance.currentUser!.uid; //
    // Replace with actual user ID
    print(userId);
    print(_nameController.text);
    await _firestore.collection('users').doc(userId).update({
      'userName': name,
    });
    name=_nameController.text;
    setState(() {

    });
  }

  Future<void> _updateImage() async {
    if (_image == null) return;

    // Upload image to Firebase Storage
    String userId = FirebaseAuth.instance.currentUser!.uid; // Replace with actual user ID
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

  @override
  Widget build(BuildContext context) {
    var userId=FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      body:StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").doc(userId).snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(height: 200, color: const Color(0xffCDE7C9)),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -30,
                        child: InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                              radius: 70,
                              backgroundImage: _image != null

                                  ? FileImage(_image!)
                                  : snapshot.data?['image'] != ""
                                  ? NetworkImage(snapshot.data?['image'],scale: 0.9)
                                  : AssetImage("images/Mask group.png",) ,
                            ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        right: 0,
                        left: MediaQuery.of(context).size.width * 0.2,
                        child: IconButton(

                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                     "${ snapshot.data!["userName"]}  ",
                        style: TextStyle(fontSize: 24, color: Colors.green),
                      ),
                      InkWell(
                        child: Image.asset(
                          "images/Group(2).png",
                          color: AppColors.primaryColor,
                        ),
                        onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (_)=>EditProfile())) ;                       },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(children: [
                    SizedBox(width: 40),
                    Expanded(child: Divider()),
                    SizedBox(width: 40),
                  ]),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Personal Information',
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Apple Health Connect',
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Change Password',
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('About Us',
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Privacy Policy',
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
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
