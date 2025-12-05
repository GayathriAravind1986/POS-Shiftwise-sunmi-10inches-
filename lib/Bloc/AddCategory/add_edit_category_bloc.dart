import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class CategoryEvent {}

class StockInLocation extends CategoryEvent {}

class SaveCategory extends CategoryEvent {
  String name;
  bool isDefault;
  String locId;
  String pickedImageName;
  final File? imageFile; // ANDROID / SUNMI
  final Uint8List? imageBytes;
  SaveCategory(
    this.name,
    this.isDefault,
    this.locId,
    this.pickedImageName, {
    this.imageFile,
    this.imageBytes,
  });
}

class AddCategory extends CategoryEvent {
  String search;
  String locId;
  bool? isDefault;
  int offset;
  int limit;
  AddCategory(this.search, this.locId, this.isDefault, this.offset, this.limit);
}

class CategoryById extends CategoryEvent {
  String categoryId;
  CategoryById(this.categoryId);
}

class UpdateCategory extends CategoryEvent {
  String categoryId;
  String name;
  bool isDefault;
  String locId;
  String pickedImageName;
  final File? imageFile;
  final Uint8List? imageBytes;
  UpdateCategory(this.categoryId, this.name, this.isDefault, this.locId,
      this.pickedImageName,
      {this.imageFile, this.imageBytes});
}

class DeleteCategory extends CategoryEvent {
  String categoryId;
  DeleteCategory(this.categoryId);
}

class CategoryBloc extends Bloc<CategoryEvent, dynamic> {
  CategoryBloc() : super(dynamic) {
    on<StockInLocation>((event, emit) async {
      await ApiProvider().getLocationAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<SaveCategory>((event, emit) async {
      await ApiProvider()
          .postCategoryAPI(
        event.name,
        event.isDefault,
        event.locId,
        event.pickedImageName,
        imageFile: event.imageFile, // <-- PASS FILE
        imageBytes: event.imageBytes,
      )
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<AddCategory>((event, emit) async {
      await ApiProvider()
          .getAddCategoryListAPI(event.search, event.locId, event.isDefault,
              event.offset, event.limit)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<CategoryById>((event, emit) async {
      await ApiProvider().getSingleCategoryAPI(event.categoryId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<UpdateCategory>((event, emit) async {
      await ApiProvider()
          .putCategoryAPI(event.categoryId, event.name, event.isDefault,
              event.locId, event.pickedImageName,
              imageFile: event.imageFile, imageBytes: event.imageBytes)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<DeleteCategory>((event, emit) async {
      await ApiProvider().deleteCategoryAPI(event.categoryId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
  }
}
