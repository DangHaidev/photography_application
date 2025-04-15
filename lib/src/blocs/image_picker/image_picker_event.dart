part of 'image_picker_bloc.dart';

abstract class ImagePickerEvent extends Equatable {
  const ImagePickerEvent();

  @override
  List<Object?> get props => [];
}

class LoadGalleryImages extends ImagePickerEvent {}

class SelectImage extends ImagePickerEvent {
  final File image;

  const SelectImage(this.image);

  @override
  List<Object?> get props => [image];
}

class PickImageFromCamera extends ImagePickerEvent {}
