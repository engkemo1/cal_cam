import 'package:flutter/material.dart';


class Validators {
  static String? validateFullName(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return "please enter your full name";
    }
    return null;
  }
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return "please enter your email";
    }
    return null;
  }
  static String? validateName(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return "Please enter your name";
    }
    return null;
  }

  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword, BuildContext context) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return "Please Confirm Your Password";
    }
    if (password != confirmPassword) {
      return "Password does mot match";
    }
    return null;
  }

  // static String? validateEmail(String? value, BuildContext context) {
  //   var translate = translation(context);
  //   if (value == null || value.isEmpty) {
  //     return translate.pleaseEnterEmail;
  //   }
  //   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
  //     return translate.invalidEmail;
  //   }
  //   return null;
  // }

  static String? validatePhoneNumber(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return "Please Enter A Phone Number";
    }
    if (!RegExp(r'^\d{9}$').hasMatch(value)) {
      return "Please Enter A Valid Phone Number";
    }
    return null;
  }
}
