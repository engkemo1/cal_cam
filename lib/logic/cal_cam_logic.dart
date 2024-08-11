import 'dart:io';
import 'package:dio/dio.dart';

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
      options: Options()
    );

    // Handle the response
    if (response.statusCode == 200) {
      final responseBody = response.data;
      String predictedLabel = responseBody['predicted_label'];
      String caloriesInfo = responseBody['calories_info'];
      print('Predicted Label: $predictedLabel');
      print('Calories Info: $caloriesInfo');
  return responseBody;

    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to upload image: $e');
  }
}
