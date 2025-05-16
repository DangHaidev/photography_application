import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ImagePickerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGalleryImages extends ImagePickerEvent {}

class PickImageFromCamera extends ImagePickerEvent {}

class SelectImage extends ImagePickerEvent {
  final File image;

  SelectImage(this.image);

  @override
  List<Object?> get props => [image];
}
class ToggleImageSelection extends ImagePickerEvent {
  final File image;
  ToggleImageSelection(this.image);
}
