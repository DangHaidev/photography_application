// lib/blocs/image_picker/image_picker_bloc.dart

import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

part 'image_picker_event.dart';
part 'image_picker_state.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  final ImagePicker _imagePicker = ImagePicker();

  ImagePickerBloc() : super(ImagePickerInitial()) {
    on<LoadGalleryImages>(_onLoadGalleryImages);
    on<SelectImage>(_onSelectImage);
    on<PickImageFromCamera>(_onPickImageFromCamera);
  }

  Future<void> _onLoadGalleryImages(
    LoadGalleryImages event,
    Emitter<ImagePickerState> emit,
  ) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      emit(ImagePickerError("Permission denied"));
      return;
    }

    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListPaged(page: 0, size: 100);

    final fileList = <File>[];
    for (final asset in recentAssets) {
      final file = await asset.file;
      if (file != null) fileList.add(file);
    }

    final preview = fileList.isNotEmpty ? fileList.first : null;
    emit(ImagePickerLoaded(images: fileList, selectedImage: preview));
  }

  void _onSelectImage(
    SelectImage event,
    Emitter<ImagePickerState> emit,
  ) {
    if (state is ImagePickerLoaded) {
      final currentState = state as ImagePickerLoaded;
      emit(ImagePickerLoaded(images: currentState.images, selectedImage: event.image));
    }
  }

  Future<void> _onPickImageFromCamera(
    PickImageFromCamera event,
    Emitter<ImagePickerState> emit,
  ) async {
    final picked = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final newImage = File(picked.path);
      if (state is ImagePickerLoaded) {
        final currentState = state as ImagePickerLoaded;
        final newList = [newImage, ...currentState.images];
        emit(ImagePickerLoaded(images: newList, selectedImage: newImage));
      } else {
        emit(ImagePickerLoaded(images: [newImage], selectedImage: newImage));
      }
    }
  }
}
