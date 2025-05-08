import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photography_application/core/navigation/router.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_bloc.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_event.dart';
import 'package:photography_application/src/blocs/image_picker/image_picker_state.dart';

class ImagePickerScreen extends StatelessWidget {
  const ImagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImagePickerBloc()..add(LoadGalleryImages()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'New post',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if ((context.read<ImagePickerBloc>().state as ImagePickerLoaded)
                        .selectedImage !=
                    null) {
                  AppRouter.router.navigateTo(context, "/editpost");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vui lòng chọn một ảnh trước")),
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
        body: BlocBuilder<ImagePickerBloc, ImagePickerState>(
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
              return CustomScrollView(
                slivers: [
                  // Ảnh preview (SliverAppBar)
                  SliverAppBar(
                    expandedHeight: 400,
                    backgroundColor: Colors.black,
                    flexibleSpace: FlexibleSpaceBar(
                      background:
                          state.selectedImage != null
                              ? Image.file(
                                state.selectedImage!,
                                fit: BoxFit.cover,
                              )
                              : Container(color: Colors.black),
                    ),
                  ),

                  // Header
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mới đây',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Row(
                            children: [
                              Icon(Icons.layers_outlined, color: Colors.white),
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
                  ),

                  // Grid ảnh
                  SliverPadding(
                    padding: EdgeInsets.all(1),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final image = state.images[index];
                        return GestureDetector(
                          onTap: () {
                            context.read<ImagePickerBloc>().add(
                              SelectImage(image),
                            );
                          },
                          child: Image.file(image, fit: BoxFit.cover),
                        );
                      }, childCount: state.images.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                    ),
                  ),
                ],
              );
            }

            return SizedBox.shrink();
          },
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}
