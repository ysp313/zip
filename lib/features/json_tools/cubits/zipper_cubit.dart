import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unzip/core/services/zipper_service.dart';

enum ZipperStatus { initial, loading, validated, compressed, error }

class ZipperState {
  final String jsonInput;
  final String compressedData;
  final String errorMessage;
  final ZipperStatus status;
  final Map<String, dynamic>? jsonData;
  final bool isFileLoaded;
  final String? fileName;

  const ZipperState({
    this.jsonInput = '',
    this.compressedData = '',
    this.errorMessage = '',
    this.status = ZipperStatus.initial,
    this.jsonData,
    this.isFileLoaded = false,
    this.fileName,
  });

  ZipperState copyWith({
    String? jsonInput,
    String? compressedData,
    String? errorMessage,
    ZipperStatus? status,
    Map<String, dynamic>? jsonData,
    bool? isFileLoaded,
    String? fileName,
  }) {
    return ZipperState(
      jsonInput: jsonInput ?? this.jsonInput,
      compressedData: compressedData ?? this.compressedData,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      jsonData: jsonData ?? this.jsonData,
      isFileLoaded: isFileLoaded ?? this.isFileLoaded,
      fileName: fileName ?? this.fileName,
    );
  }
}

class ZipperCubit extends Cubit<ZipperState> {
  final ZipperService _zipperService;

  ZipperCubit({ZipperService? zipperService})
      : _zipperService = zipperService ?? const ZipperService(),
        super(const ZipperState());

  void setJsonInput(String value) {
    if (state.status == ZipperStatus.error ||
        state.status == ZipperStatus.compressed) {
      emit(state.copyWith(
        jsonInput: value,
        status: ZipperStatus.initial,
      ));
    } else {
      emit(state.copyWith(jsonInput: value));
    }
  }

  void setFileName(String? name) {
    emit(state.copyWith(fileName: name));
  }

  void setFileLoaded(bool value) {
    emit(state.copyWith(isFileLoaded: value));
  }

  Future<void> validateJson() async {
    if (state.jsonInput.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please enter JSON data',
        status: ZipperStatus.error,
      ));
      return;
    }

    emit(state.copyWith(status: ZipperStatus.loading));

    try {
      final jsonData = jsonDecode(state.jsonInput) as Map<String, dynamic>;
      emit(state.copyWith(
        jsonData: jsonData,
        status: ZipperStatus.validated,
      ));
    } on FormatException catch (e) {
      emit(state.copyWith(
        errorMessage: 'Invalid JSON format: ${e.message}',
        status: ZipperStatus.error,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        status: ZipperStatus.error,
      ));
    }
  }

  Future<void> compressData() async {
    if (state.jsonData == null) return;

    emit(state.copyWith(status: ZipperStatus.loading));

    try {
      final compressedData = _zipperService.zip(state.jsonData!);

      emit(state.copyWith(
        compressedData: compressedData,
        status: ZipperStatus.compressed,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Error during compression: ${e.toString()}',
        status: ZipperStatus.error,
      ));
    }
  }

  void reset() {
    emit(const ZipperState());
  }
}
