import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'image_picker_event.dart';
import 'image_picker_state.dart';

// Model để lưu thông tin ảnh và caption
class ImageWithCaption {
  final File imageFile;
  final String? caption;
  final bool isUploading;

  ImageWithCaption({
    required this.imageFile,
    this.caption,
    this.isUploading = false,
  });

  ImageWithCaption copyWith({
    File? imageFile,
    String? caption,
    bool? isUploading,
  }) {
    return ImageWithCaption(
      imageFile: imageFile ?? this.imageFile,
      caption: caption ?? this.caption,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  final ImagePicker _picker = ImagePicker();

  ImagePickerBloc() : super(ImagePickerInitial()) {
    on<LoadGalleryImages>(_onLoadGalleryImages);
    on<PickImageFromCamera>(_onPickImageFromCamera);
    on<ToggleImageSelection>(_onToggleImageSelection);
    on<UpdateImageCaption>(_onUpdateImageCaption);
  }

  Future<void> _onLoadGalleryImages(
      LoadGalleryImages event, Emitter<ImagePickerState> emit) async {
    try {
      emit(ImagePickerLoading());

      final List<XFile> pickedFiles =
      await _picker.pickMultiImage(imageQuality: 80);

      final imagesWithCaption = pickedFiles
          .map((xfile) => ImageWithCaption(
        imageFile: File(xfile.path),
        isUploading: true,
      ))
          .toList();

      emit(ImagePickerLoaded(imagesWithCaption: imagesWithCaption));




      // Gửi từng ảnh lên webhook và cập nhật caption

      // for (int i = 0; i < imagesWithCaption.length; i++) {
      //   final imageWithCaption = imagesWithCaption[i];
      //   final caption = await uploadImageToWebhook(imageWithCaption.imageFile);

      //   // Cập nhật caption cho ảnh này
      //   add(UpdateImageCaption(
      //     imageFile: imageWithCaption.imageFile,
      //     caption: caption,
      //   ));
      // }




    } catch (e) {
      emit(ImagePickerError("Can not load image gallery."));
    }
  }

  Future<void> _onPickImageFromCamera(
      PickImageFromCamera event, Emitter<ImagePickerState> emit) async {
    try {
      final XFile? photo =
      await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

      if (photo == null) return;

      final newImageWithCaption = ImageWithCaption(
        imageFile: File(photo.path),
        isUploading: true,
      );

      final currentState = state;
      if (currentState is ImagePickerLoaded) {
        final updatedImages = [newImageWithCaption, ...currentState.imagesWithCaption];
        final updatedSelected = [...currentState.selectedImages, newImageWithCaption];

        emit(currentState.copyWith(
          imagesWithCaption: updatedImages,
          selectedImages: updatedSelected,
        ));
      } else {
        emit(ImagePickerLoaded(
          imagesWithCaption: [newImageWithCaption],
          selectedImages: [newImageWithCaption],
        ));
      }

      // Gửi ảnh lên webhook và cập nhật caption
      // final caption = await uploadImageToWebhook(newImageWithCaption.imageFile);
      // add(UpdateImageCaption(
      //   imageFile: newImageWithCaption.imageFile,
      //   caption: caption,
      // ));
    } catch (e) {
      emit(ImagePickerError("Can not open the camera."));
    }
  }

  void _onToggleImageSelection(
      ToggleImageSelection event, Emitter<ImagePickerState> emit) {
    final currentState = state;
    if (currentState is ImagePickerLoaded) {
      final selected = List<ImageWithCaption>.from(currentState.selectedImages);

      // Tìm ImageWithCaption tương ứng với File
      final imageWithCaption = currentState.imagesWithCaption
          .firstWhere((img) => img.imageFile.path == event.image.path);

      if (selected.any((img) => img.imageFile.path == event.image.path)) {
        selected.removeWhere((img) => img.imageFile.path == event.image.path);
      } else {
        selected.add(imageWithCaption);
      }

      emit(currentState.copyWith(selectedImages: selected));
    }
  }

  void _onUpdateImageCaption(
      UpdateImageCaption event, Emitter<ImagePickerState> emit) {
    final currentState = state;
    if (currentState is ImagePickerLoaded) {
      // Cập nhật caption cho ảnh tương ứng
      final updatedImages = currentState.imagesWithCaption.map((img) {
        if (img.imageFile.path == event.imageFile.path) {
          return img.copyWith(
            caption: event.caption,
            isUploading: false,
          );
        }
        return img;
      }).toList();

      // Cập nhật selected images
      final updatedSelected = currentState.selectedImages.map((img) {
        if (img.imageFile.path == event.imageFile.path) {
          return img.copyWith(
            caption: event.caption,
            isUploading: false,
          );
        }
        return img;
      }).toList();

      emit(currentState.copyWith(
        imagesWithCaption: updatedImages,
        selectedImages: updatedSelected,
      ));
    }
  }

  /// Hàm gửi ảnh lên webhook và nhận caption
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
        final jsonResponse = json.decode(responseBody);

        // Giả sử webhook trả về caption trong field 'caption' hoặc 'description'
        return jsonResponse['caption'] ??
            jsonResponse['description'] ??
            jsonResponse['text'] ??
            'No caption available';
      } else {
        throw Exception('Image upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      return 'Failed to generate caption';
    }
  }
}