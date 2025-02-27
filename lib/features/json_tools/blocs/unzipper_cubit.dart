import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_saver/file_saver.dart';

class UnzipperState extends Equatable {
  final String compressedContent;
  final String decompressedContent;
  final bool isLoading;
  final String? error;

  const UnzipperState({
    this.compressedContent = '',
    this.decompressedContent = '',
    this.isLoading = false,
    this.error,
  });

  UnzipperState copyWith({
    String? compressedContent,
    String? decompressedContent,
    bool? isLoading,
    String? error,
  }) {
    return UnzipperState(
      compressedContent: compressedContent ?? this.compressedContent,
      decompressedContent: decompressedContent ?? this.decompressedContent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [compressedContent, decompressedContent, isLoading, error];
}

class UnzipperCubit extends Cubit<UnzipperState> {
  UnzipperCubit() : super(const UnzipperState());

  void updateCompressedContent(String content) {
    emit(state.copyWith(compressedContent: content, error: null));
  }

  Future<void> decompressJson() async {
    try {
      if (state.compressedContent.isEmpty) {
        emit(state.copyWith(error: 'Please enter compressed JSON content'));
        return;
      }

      emit(state.copyWith(isLoading: true));
      final jsonObject = json.decode(state.compressedContent);
      final prettyString = const JsonEncoder.withIndent('  ').convert(jsonObject);
      emit(state.copyWith(
        decompressedContent: prettyString,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error decompressing JSON: $e',
      ));
    }
  }

  Future<void> saveDecompressedContent() async {
    try {
      if (state.decompressedContent.isEmpty) {
        emit(state.copyWith(error: 'No decompressed content to save'));
        return;
      }

      await FileSaver.instance.saveFile(
        name: 'decompressed.json',
        bytes: utf8.encode(state.decompressedContent),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Error saving file: $e'));
    }
  }

  void reset() {
    emit(const UnzipperState());
  }
}