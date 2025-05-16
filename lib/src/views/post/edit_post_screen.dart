import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photography_application/src/blocs/post/up_post.dart';
import 'package:photography_application/src/blocs/post/upload_image.dart';

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
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        leading: BackButton(color: Colors.black),
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
                                "/profileMe",
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
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? null                   
                        : Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
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
