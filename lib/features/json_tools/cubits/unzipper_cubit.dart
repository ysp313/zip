import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unzip/core/services/zipper_service.dart';

enum UnzipperStatus {
  initial,
  loading,
  unzipped,
  editing,
  recompressing,
  error
}

class UnzipperState {
  final String inputData;
  final String jsonOutput;
  final String recompressedData;
  final String errorMessage;
  final UnzipperStatus status;
  final Map<String, dynamic>? jsonData;
  final bool isEdited;

  const UnzipperState({
    this.inputData = '',
    this.jsonOutput = '',
    this.recompressedData = '',
    this.errorMessage = '',
    this.status = UnzipperStatus.initial,
    this.jsonData,
    this.isEdited = false,
  });

  UnzipperState copyWith({
    String? inputData,
    String? jsonOutput,
    String? recompressedData,
    String? errorMessage,
    UnzipperStatus? status,
    Map<String, dynamic>? jsonData,
    bool? isEdited,
  }) {
    return UnzipperState(
      inputData: inputData ?? this.inputData,
      jsonOutput: jsonOutput ?? this.jsonOutput,
      recompressedData: recompressedData ?? this.recompressedData,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      jsonData: jsonData ?? this.jsonData,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

class UnzipperCubit extends Cubit<UnzipperState> {
  final ZipperService _zipperService;

  UnzipperCubit({ZipperService? zipperService})
      : _zipperService = zipperService ?? const ZipperService(),
        super(const UnzipperState());

  void setInputData(String value) {
    if (state.status == UnzipperStatus.error ||
        state.status == UnzipperStatus.unzipped) {
      emit(state.copyWith(
        inputData: value,
        status: UnzipperStatus.initial,
      ));
    } else {
      emit(state.copyWith(inputData: value));
    }
  }

  void setJsonOutput(String value) {
    emit(state.copyWith(
      jsonOutput: value,
      isEdited: true,
    ));
  }

  Future<void> unzipData() async {
    if (state.inputData.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please enter compressed data',
        status: UnzipperStatus.error,
      ));
      return;
    }

    emit(state.copyWith(status: UnzipperStatus.loading));

    try {
      final jsonData = _zipperService.unzip(state.inputData);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);

      emit(state.copyWith(
        jsonOutput: prettyJson,
        jsonData: jsonData,
        status: UnzipperStatus.unzipped,
      ));
    } on FormatException catch (e) {
      emit(state.copyWith(
        errorMessage: 'Invalid compressed data format: ${e.message}',
        status: UnzipperStatus.error,
      ));
    }
  }

  void startEditing() {
    emit(state.copyWith(status: UnzipperStatus.editing));
  }

  void stopEditing() {
    emit(state.copyWith(
      status: UnzipperStatus.unzipped,
      isEdited: false,
    ));
  }

  void applyEdits() {
    try {
      final jsonData = jsonDecode(state.jsonOutput) as Map<String, dynamic>;
      emit(state.copyWith(
        jsonData: jsonData,
        status: UnzipperStatus.unzipped,
        isEdited: false,
      ));
    } on FormatException catch (e) {
      emit(state.copyWith(
        errorMessage: 'Invalid JSON format: ${e.message}',
        status: UnzipperStatus.error,
      ));
    }
  }

  Future<void> recompressJson() async {
    if (state.jsonData == null) return;

    emit(state.copyWith(status: UnzipperStatus.recompressing));

    try {
      final compressedData = _zipperService.zip(state.jsonData!);

      emit(state.copyWith(
        recompressedData: compressedData,
        status: UnzipperStatus.unzipped,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Error during recompression: ${e.toString()}',
        status: UnzipperStatus.error,
      ));
    }
  }

  void reset() {
    emit(const UnzipperState());
  }
}
