import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photography_application/src/blocs/post/up_post.dart';
import 'package:photography_application/src/blocs/post/upload_image.dart';

class MediaEditScreen extends StatefulWidget {
  final List<File> selectedImages;

  const MediaEditScreen({super.key, required this.selectedImages});

  @override
  State<MediaEditScreen> createState() => _MediaEditScreenState();
}

class _MediaEditScreenState extends State<MediaEditScreen> {
  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton(
              onPressed: () async {

                List<String> imageUrls = [];
                for(File image in widget.selectedImages){
                  String? uploadedUrl = await uploadImageToPostImages(image);
                  if(uploadedUrl != null)
                    {
                      imageUrls.add(uploadedUrl);
                    }
                }

                if (imageUrls != null) {
                  await submitPost(
                    caption: captionController.text,
                    imageUrls: imageUrls,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Upload ảnh thất bại")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Submit"),
            ),
          ),
        ],
      ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Display each image in the list
              for (File image in widget.selectedImages)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(image),
                ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Text('Delete this media'),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildTextField("Title", "Add Title", captionController),
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

  // Widget _buildTextField(String label, String hint) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text("$label (Optional)", style: TextStyle(color: Colors.black87)),
  //       SizedBox(height: 8),
  //       TextField(
  //         decoration: InputDecoration(
  //           hintText: hint,
  //           filled: true,
  //           fillColor: Colors.grey.shade100,
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide.none,
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 20),
  //     ],
  //   );
  // }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label (Optional)", style: TextStyle(color: Colors.black87)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
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
