import 'dart:io';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photography_application/core/navigation/router.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_bloc.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_event.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_state.dart';
import 'package:photography_application/src/views/post/edit_post_screen.dart';

class ImagePickerScreen extends StatelessWidget {
  const ImagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImagePickerBloc()..add(LoadGalleryImages()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
            builder: (context, state) {
              if (state is ImagePickerLoading || state is ImagePickerInitial) {
                return Center(child: CircularProgressIndicator());
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
                  headerSliverBuilder:
                      (context, innerBoxIsScrolled) => [
                        SliverAppBar(
                          backgroundColor: Colors.black,
                          pinned: true,
                          expandedHeight: 350,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Padding(
                              padding: EdgeInsets.only(
                                top: 35,
                              ), // hoặc MediaQuery.of(context).padding.top nếu muốn dựa vào hệ thống
                              child:
                                  state.selectedImage != null
                                      ? Image.file(
                                        state.selectedImage!,
                                        fit: BoxFit.contain,
                                      )
                                      : Container(color: Colors.black),
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
                                final selectedImage = state.selectedImage;
                                if (selectedImage != null) {
                                  final imagePath = Uri.encodeComponent(
                                    selectedImage.path,
                                  );
                                  AppRouter.router.navigateTo(
                                    context,
                                    "/editpost?path=$imagePath",
                                    transition: TransitionType.cupertino,
                                  );
                                }
                              },
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.blue,
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
                                Icon(
                                  Icons.layers_outlined,
                                  color: Colors.white,
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
                                crossAxisCount: 4,
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 1,
                              ),
                          itemCount: state.images.length,
                          itemBuilder: (context, index) {
                            final image = state.images[index];
                            return GestureDetector(
                              onTap: () {
                                context.read<ImagePickerBloc>().add(
                                  SelectImage(image),
                                );
                              },
                              child: Image.file(image, fit: BoxFit.cover),
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
}
