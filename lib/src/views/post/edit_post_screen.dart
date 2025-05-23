import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photography_application/src/blocs/post/up_post.dart';
import 'package:photography_application/src/blocs/post/upload_image.dart';


import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MediaEditScreen extends StatefulWidget {
  final List<File> selectedImages;

  const MediaEditScreen({
    super.key,
    required this.selectedImages,
    required List<File> images,
  });

  @override
  State<MediaEditScreen> createState() => _MediaEditScreenState();
}

class _MediaEditScreenState extends State<MediaEditScreen> {
  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  late List<File> _editableImages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editableImages = List.from(widget.selectedImages);
     _generateCaption();
  }


Future<void> _generateCaption() async {
    if (widget.selectedImages.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final caption = await uploadImageToWebhook(widget.selectedImages.first);

      setState(() {
        captionController.text = caption ?? '';
        _isLoading = false;
      });
    }
  }


// Future<String?> uploadImageToWebhook(File imageFile) async {
//   try {
//     final uri = Uri.parse(
//         'https://thuan23082004.app.n8n.cloud/webhook-test/26d0cda8-01d5-4542-b0c9-9ed99ecda343');

//     final request = http.MultipartRequest('POST', uri)
//       ..files.add(await http.MultipartFile.fromPath(
//         'file',
//         imageFile.path,
//         contentType: MediaType('image', 'jpeg'),
//       ));

//     final response = await request.send();

//     if (response.statusCode == 200) {
//       final responseBody = await response.stream.bytesToString();
//       final jsonResponse = json.decode(responseBody);
//       return jsonResponse['caption'] ??
//           jsonResponse['description'] ??
//           jsonResponse['text'] ??
//           'No caption available';
//     } else {
//       throw Exception('Image upload failed with status: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Upload error: $e');
//     return 'Failed to generate caption';
//   }
// }



Future<String?> uploadImageToWebhook(File imageFile) async {
  try {
    final uri = Uri.parse(
        'https://thuan23082004.app.n8n.cloud/webhook/26d0cda8-01d5-4542-b0c9-9ed99ecda343');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      return responseBody;



  //     final decoded = json.decode(responseBody);
  // print('DECODED JSON: $decoded');
  //     if (decoded is Map<String, dynamic>) {
  //       return decoded['caption'] ??
  //           decoded['description'] ??
  //           decoded['text'] ??
  //           'No caption available';
  //     } else if (decoded is String) {
  //       return decoded;
  //     } else {
  //       return 'No caption found';
  //     }
    } else {
      throw Exception('Image upload failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Upload error: $e');
    return 'Failed to generate caption';
  }
}




  @override
  void dispose() {
    captionController.dispose();
    locationController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 206, 7, 7),
        elevation: 0,
        leading: BackButton(color: Theme.of(context).colorScheme.secondary),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Visibility(
              visible: !_isLoading,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          if (_editableImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("at least 1 image")),
                            );
                            return;
                          }

                          setState(() => _isLoading = true); // loading

                          try {
                            List<String> uploadedUrls =
                                await uploadImageToPostImages(_editableImages);

                            await submitPost(
                              caption: captionController.text,
                              imageUrls: uploadedUrls,
                            );

                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                "/home",
                                (_) => false,
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Upload fail")),
                            );
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? null
                        : Text(
                          "Submit",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.secondary, // Màu đen trong light mode
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ) // 👈 Hiển thị khi đang xử lý
              : SingleChildScrollView(
                child: Column(
                  children: [
                    if (_editableImages.isNotEmpty)
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          itemCount: _editableImages.length,
                          itemBuilder: (context, index) {
                            final image = _editableImages[index];
                            return Stack(
                              children: [
                                Center(
                                  child: Image.file(image, fit: BoxFit.contain),
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _editableImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Không có ảnh nào được chọn',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Information",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            "Caption",
                            "Add caption",
                            captionController,
                          ),
                          _buildTextField(
                            "Location",
                            "Enter Location",
                            locationController,
                          ),
                          _buildTextField(
                            "Tags",
                            "Enter tags for this media...",
                            tagsController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label (Optional)",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color.fromARGB(255, 10, 10, 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
