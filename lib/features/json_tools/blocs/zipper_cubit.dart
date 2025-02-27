import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';

class ZipperState extends Equatable {
  final String jsonContent;
  final String compressedContent;
  final bool isLoading;
  final String? error;

  const ZipperState({
    this.jsonContent = '',
    this.compressedContent = '',
    this.isLoading = false,
    this.error,
  });

  ZipperState copyWith({
    String? jsonContent,
    String? compressedContent,
    bool? isLoading,
    String? error,
  }) {
    return ZipperState(
      jsonContent: jsonContent ?? this.jsonContent,
      compressedContent: compressedContent ?? this.compressedContent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [jsonContent, compressedContent, isLoading, error];
}

class ZipperCubit extends Cubit<ZipperState> {
  ZipperCubit() : super(const ZipperState());

  void updateJsonContent(String content) {
    emit(state.copyWith(jsonContent: content, error: null));
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final content = utf8.decode(result.files.first.bytes!);
        emit(state.copyWith(jsonContent: content, error: null));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error picking file: $e'));
    }
  }

  Future<void> compressJson() async {
    try {
      if (state.jsonContent.isEmpty) {
        emit(state.copyWith(error: 'Please enter JSON content'));
        return;
      }

      emit(state.copyWith(isLoading: true));
      final jsonObject = json.decode(state.jsonContent);
      final compressedString = json.encode(jsonObject);
      emit(state.copyWith(
        compressedContent: compressedString,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error compressing JSON: $e',
      ));
    }
  }

  Future<void> saveCompressedContent() async {
    try {
      if (state.compressedContent.isEmpty) {
        emit(state.copyWith(error: 'No compressed content to save'));
        return;
      }

      await FileSaver.instance.saveFile(
        name: 'compressed.json',
        bytes: utf8.encode(state.compressedContent),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Error saving file: $e'));
    }
  }

  void reset() {
    emit(const ZipperState());
  }
}