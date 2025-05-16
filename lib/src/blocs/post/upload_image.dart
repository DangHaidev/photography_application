import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Future<List<String?>> uploadImageToPostImages(File imageFile) async {
//   const String apiKey = 'dbf320a3976c5a03d28c58d67f4edae1'; // 🔐 Thay bằng API key từ imgbb.com
//   final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

//   // Đọc file ảnh thành base64
//   final base64Image = base64Encode(await imageFile.readAsBytes());

//   final response = await http.post(
//     url,
//     body: {
//       'image': base64Image,
//       // Optional: 'name': 'your_filename',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return data['data']['url']; // Đây là link ảnh
//   } else {
//     print('Upload failed: ${response.body}');
//     return null;
//   }
// }


Future<List<String>> uploadImageToPostImages(List<File> imageFiles) async {
  const String apiKey = 'dbf320a3976c5a03d28c58d67f4edae1'; // 🔐 Thay bằng API key thực tế
  final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

  List<String> uploadedUrls = [];

  for (final imageFile in imageFiles) {
    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await http.post(
        url,
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        uploadedUrls.add(data['data']['url']);
      } else {
        print('❌ Upload failed: ${response.body}');
        // Bạn có thể chọn `continue` hoặc `return null` nếu muốn dừng khi có lỗi
      }
    } catch (e) {
      print('❌ Exception during upload: $e');
      // Tùy chọn: throw hoặc return danh sách chưa đầy đủ
    }
  }

  return uploadedUrls;
}
