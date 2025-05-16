import 'dart:io';

abstract class ImagePickerState {}

class ImagePickerInitial extends ImagePickerState {}

class ImagePickerLoading extends ImagePickerState {}

class ImagePickerLoaded extends ImagePickerState {
  final List<File> images;
  final List<File> selectedImages;

  ImagePickerLoaded({
    required this.images,
    this.selectedImages = const [],
  });

  ImagePickerLoaded copyWith({
    List<File>? images,
    List<File>? selectedImages,
  }) {
    return ImagePickerLoaded(
      images: images ?? this.images,
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}

class ImagePickerError extends ImagePickerState {
  final String message;
  ImagePickerError(this.message);
}
