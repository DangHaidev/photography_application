import 'package:flutter/material.dart';


class MediaEditScreen extends StatelessWidget {
  final String selectedImageUrl =
      'https://picsum.photos/seed/selected/600/400'; // ảnh demo

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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Submit"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Ảnh có kích thước gốc và cuộn theo
            Image.network(selectedImageUrl),

            const SizedBox(height: 12),
            // Nút Delete
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
            // Form thông tin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  _buildTextField("Title", "Add Title"),
                  _buildTextField("Location", "Enter Location"),
                  _buildTextField("Tags", "Enter tags for this media..."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label (Optional)", style: TextStyle(color: Colors.black87)),
        SizedBox(height: 8),
        TextField(
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