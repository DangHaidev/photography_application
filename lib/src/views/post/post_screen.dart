import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_bloc.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_event.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_state.dart';
import 'package:photography_application/src/views/post/edit_post_screen.dart';
import 'package:photography_application/core/blocs/theme_provider.dart';
import 'package:provider/provider.dart';

class ImagePickerScreen extends StatelessWidget {
  const ImagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return BlocProvider(
      create: (_) => ImagePickerBloc()..add(LoadGalleryImages()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
            builder: (context, state) {
              if (state is ImagePickerLoading || state is ImagePickerInitial) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Loading images...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              if (state is ImagePickerError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (state is ImagePickerLoaded) {
                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      backgroundColor: Colors.black,
                      pinned: true,
                      expandedHeight: 450, // Tăng chiều cao để chứa caption
                      flexibleSpace: FlexibleSpaceBar(
                        background: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: state.selectedImages.isNotEmpty
                              ? Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Image.file(
                                  state.selectedImages.last.imageFile,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // Hiển thị caption
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'AI Caption',
                                            style: TextStyle(
                                              color: Colors.amber,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: _buildCaptionWidget(
                                            state.selectedImages.last,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                              : Container(
                            color: Theme.of(context).primaryColor,
                            child: Center(
                              child: Text(
                                'Select an image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      leading: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Text(
                        'New post',
                        style: TextStyle(color: Colors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            final selectedImages = state.selectedImages;
                            if (selectedImages.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MediaEditScreen(
                                    selectedImages: selectedImages
                                        .map((img) => img.imageFile)
                                        .toList(),
                                    images: [],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  body: Column(
                    children: [
                      Container(
                        color: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.read<ImagePickerBloc>().add(
                                      LoadGalleryImages(),
                                    );
                                  },
                                  child: Icon(
                                    Icons.layers_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    context.read<ImagePickerBloc>().add(
                                      PickImageFromCamera(),
                                    );
                                  },
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(1),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Giảm xuống 3 để có không gian hiển thị caption
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 0.8, // Tỷ lệ để có không gian cho text
                          ),
                          itemCount: state.imagesWithCaption.length,
                          itemBuilder: (context, index) {
                            final imageWithCaption = state.imagesWithCaption[index];
                            final isSelected = state.selectedImages.any(
                                  (img) => img.imageFile.path == imageWithCaption.imageFile.path,
                            );

                            return GestureDetector(
                              onTap: () {
                                context.read<ImagePickerBloc>().add(
                                  ToggleImageSelection(imageWithCaption.imageFile),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(color: Colors.blue, width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                            child: Image.file(
                                              imageWithCaption.imageFile,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                          if (isSelected)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          if (imageWithCaption.isUploading)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Processing...',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Caption preview
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(6),
                                          ),
                                        ),
                                        child: Text(
                                          imageWithCaption.caption?.substring(
                                            0,
                                            imageWithCaption.caption!.length > 30
                                                ? 30
                                                : imageWithCaption.caption!.length,
                                          ) ??
                                              (imageWithCaption.isUploading
                                                  ? 'Generating...'
                                                  : 'No caption'),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCaptionWidget(ImageWithCaption imageWithCaption) {
    if (imageWithCaption.isUploading) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Generating caption...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    if (imageWithCaption.caption == null || imageWithCaption.caption!.isEmpty) {
      return Text(
        'No caption available',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      imageWithCaption.caption!,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }
}