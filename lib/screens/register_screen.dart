import 'package:cal_cam/app_colors.dart';
import 'package:cal_cam/screens/login_screen.dart';
import 'package:cal_cam/screens/main_screen/main_screen.dart';
import 'package:cal_cam/screens/widgets/custom_button.dart';
import 'package:cal_cam/screens/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passController.text,
        );

        // Add user information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'userName': userNameController.text,
          'email': emailController.text,
          'phoneNumber': phoneNumberController.text,
          "image":"",
          "consumed":0,
          "goal":0,
          "remaining":0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred. Please try again.';
        if (e.code == 'email-already-in-use') {
          message = 'The email address is already in use.';
        } else if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is not valid.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: ListView(
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_sharp,
                        size: 25,
                        color: Colors.black,
                        shadows: [Shadow(color: Colors.black, offset: Offset(1, 0))],
                      ),
                    ),
                    const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(),
                  ],
                ),
                const SizedBox(height: 40),
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
                  prefixIcon: const Text("+966", style: TextStyle(fontWeight: FontWeight.w600)),
                  validator: (v) => Validators.validatePhoneNumber(v, context),
                  hintText: "542121456",
                ),
                CustomTextField(
                  suffixIcon: _obscurePass
                      ? InkWell(
                    onTap: () {
                      setState(() {
                        _obscurePass = !_obscurePass;
                      });
                    },
                    child: const Icon(Icons.visibility_off_outlined),
                  )
                      : InkWell(
                    onTap: () {
                      setState(() {
                        _obscurePass = !_obscurePass;
                      });
                    },
                    child: const Icon(Icons.visibility_outlined),
                  ),
                  obscureText: _obscurePass,
                  labelText: "Password",
                  hintText: "***********",
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) => Validators.validatePassword(value, context),
                  controller: passController,
                ),
                const SizedBox(height: 5),
                const SizedBox(height: 20),
                CustomButton(label: "Register", onPressed: _register),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Already have an account ",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    CustomButton(
                      label: "Login",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      size: const Size(144, 25),
                      radius: 20,
                      color: Colors.white,
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      borderColor: AppColors.secondaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
