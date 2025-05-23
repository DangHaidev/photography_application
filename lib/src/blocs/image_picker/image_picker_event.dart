import 'dart:io';

abstract class ImagePickerEvent {}

class LoadGalleryImages extends ImagePickerEvent {}

class PickImageFromCamera extends ImagePickerEvent {}

class ToggleImageSelection extends ImagePickerEvent {
  final File image;

  ToggleImageSelection(this.image);
}

class UpdateImageCaption extends ImagePickerEvent {
  final File imageFile;
  final String? caption;

  UpdateImageCaption({
    required this.imageFile,
    required this.caption,
  });
}