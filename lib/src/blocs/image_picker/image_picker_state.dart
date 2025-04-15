// lib/blocs/image_picker/image_picker_state.dart

part of 'image_picker_bloc.dart';

abstract class ImagePickerState extends Equatable {
  const ImagePickerState();

  @override
  List<Object?> get props => [];
}

class ImagePickerInitial extends ImagePickerState {}

class ImagePickerLoading extends ImagePickerState {}

class ImagePickerLoaded extends ImagePickerState {
  final List<File> images;
  final File? selectedImage;

  const ImagePickerLoaded({required this.images, this.selectedImage});

  @override
  List<Object?> get props => [images, selectedImage];
}

class ImagePickerError extends ImagePickerState {
  final String message;

  const ImagePickerError(this.message);

  @override
  List<Object?> get props => [message];
}
