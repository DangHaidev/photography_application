import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'image_picker_event.dart';
import 'image_picker_state.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  final ImagePicker _picker = ImagePicker();

  ImagePickerBloc() : super(ImagePickerInitial()) {
    on<LoadGalleryImages>(_onLoadGalleryImages);
    on<PickImageFromCamera>(_onPickImageFromCamera);
    on<ToggleImageSelection>(_onToggleImageSelection);
  }

  Future<void> _onLoadGalleryImages(
      LoadGalleryImages event, Emitter<ImagePickerState> emit) async {
    try {
      emit(ImagePickerLoading());

      final List<XFile> pickedFiles =
          await _picker.pickMultiImage(imageQuality: 80);

      final images = pickedFiles.map((xfile) => File(xfile.path)).toList();

      emit(ImagePickerLoaded(images: images));
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

      final currentState = state;
      if (currentState is ImagePickerLoaded) {
        final newImage = File(photo.path);
        final updatedImages = [newImage, ...currentState.images];
        final updatedSelected = [...currentState.selectedImages, newImage];

        emit(currentState.copyWith(
          images: updatedImages,
          selectedImages: updatedSelected,
        ));
      }
    } catch (e) {
      emit(ImagePickerError("Can not open the camera."));
    }
  }

  void _onToggleImageSelection(
      ToggleImageSelection event, Emitter<ImagePickerState> emit) {
    final currentState = state;
    if (currentState is ImagePickerLoaded) {
      final selected = List<File>.from(currentState.selectedImages);
      if (selected.contains(event.image)) {
        selected.remove(event.image);
      } else {
        selected.add(event.image);
      }

      emit(currentState.copyWith(selectedImages: selected));
    }
  }
}
