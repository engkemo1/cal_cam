import 'package:cal_cam/app_colors.dart';
import 'package:cal_cam/screens/register_screen.dart';
import 'package:cal_cam/screens/widgets/custom_button.dart';
import 'package:cal_cam/screens/widgets/custom_clickable_Text.dart';
import 'package:cal_cam/screens/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:svg_flutter/svg.dart';
import '../validators.dart';
import 'main_screen/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim(),
        );
        // Navigate to home screen or another appropriate screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_)=>MainScreen()));
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred. Please try again.';
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is not valid.';
        } else if (e.code == 'user-disabled') {
          message = 'The user account has been disabled.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: ListView(
            children: [
              const SizedBox(height: 30),
              Stack(
                children: [
                  Image.asset("images/logo.png", height: 320),
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: SvgPicture.asset("images/Rectangle 5913.svg"),
                  ),
                ],
              ),
              CustomTextField(
                controller: emailController,
                labelText: "Email",
                hintText: "example@gmail.com",
                validator: (v) => Validators.validateEmail(v, context),
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
                hintText: "**************",
                keyboardType: TextInputType.visiblePassword,
                validator: (value) => Validators.validatePassword(value, context),
                controller: passController,
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.bottomRight,
                child: CustomClickableText(
                  text: "Reset your Password?",
                  onTap: () {

                  },
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(label: "Login", onPressed: _login),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  CustomButton(
                    label: "Sign Up",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
    );
  }
}
