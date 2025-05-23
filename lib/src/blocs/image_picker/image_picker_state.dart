import 'dart:io';
import 'image_picker_bloc.dart'; // Import để sử dụng ImageWithCaption

abstract class ImagePickerState {}

class ImagePickerInitial extends ImagePickerState {}

class ImagePickerLoading extends ImagePickerState {}

class ImagePickerLoaded extends ImagePickerState {
  final List<ImageWithCaption> imagesWithCaption;
  final List<ImageWithCaption> selectedImages;

  ImagePickerLoaded({
    required this.imagesWithCaption,
    this.selectedImages = const [],
  });

  // Getter để tương thích với code cũ
  List<File> get images => imagesWithCaption.map((img) => img.imageFile).toList();

  ImagePickerLoaded copyWith({
    List<ImageWithCaption>? imagesWithCaption,
    List<ImageWithCaption>? selectedImages,
  }) {
    return ImagePickerLoaded(
      imagesWithCaption: imagesWithCaption ?? this.imagesWithCaption,
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}

class ImagePickerError extends ImagePickerState {
  final String message;

  ImagePickerError(this.message);
}