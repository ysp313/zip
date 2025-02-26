import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unzip/core/services/zipper_service.dart';
import 'package:unzip/core/utils/exceptions.dart';

enum UnzipperState {
  initial,
  loading,
  unzipped,
  editing,
  recompressing,
  error,
}

class UnzipperController extends ChangeNotifier {
  final ZipperService _zipperService = const ZipperService();

  String _inputData = '';
  String _jsonOutput = '';
  String _recompressedData = '';
  String _errorMessage = '';
  UnzipperState _state = UnzipperState.initial;
  Map<String, dynamic>? _jsonData;
  bool _isEdited = false;

  // Getters
  String get inputData => _inputData;
  String get jsonOutput => _jsonOutput;
  String get recompressedData => _recompressedData;
  String get errorMessage => _errorMessage;
  UnzipperState get state => _state;
  bool get isEdited => _isEdited;
  Map<String, dynamic>? get jsonData => _jsonData;

  // Setters
  void setInputData(String value) {
    _inputData = value;
    // Reset state if we change input
    if (_state == UnzipperState.error || _state == UnzipperState.unzipped) {
      _state = UnzipperState.initial;
    }
    notifyListeners();
  }

  void setJsonOutput(String value) {
    _jsonOutput = value;
    _isEdited = true;
    notifyListeners();
  }

  // Action methods
  Future<void> unzipData() async {
    if (_inputData.trim().isEmpty) {
      _setError('Veuillez entrer des données compressées');
      return;
    }

    _state = UnzipperState.loading;
    notifyListeners();

    try {
      final result = await compute(_unzipDataIsolate, _inputData);

      if (result.error != null) {
        _setError(result.error!);
        return;
      }

      _jsonData = result.data;
      _jsonOutput = const JsonEncoder.withIndent('  ').convert(_jsonData);
      _state = UnzipperState.unzipped;
      _errorMessage = '';
      _isEdited = false;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la décompression: ${e.toString()}');
    }
  }

  void startEditing() {
    _state = UnzipperState.editing;
    notifyListeners();
  }

  void stopEditing() {
    _state = UnzipperState.unzipped;
    notifyListeners();
  }

  Future<void> applyEdits() async {
    if (_jsonOutput.trim().isEmpty) {
      _setError('Le contenu JSON ne peut pas être vide');
      return;
    }

    try {
      final result = await compute(_validateJsonIsolate, _jsonOutput);

      if (result.error != null) {
        _setError(result.error!);
        return;
      }

      _jsonData = result.data;
      _jsonOutput = const JsonEncoder.withIndent('  ').convert(_jsonData);
      _state = UnzipperState.unzipped;
      _errorMessage = '';
      _isEdited = false;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la validation: ${e.toString()}');
    }
  }

  Future<void> recompressJson() async {
    if (_jsonData == null) {
      _setError('Aucune donnée à compresser');
      return;
    }

    _state = UnzipperState.recompressing;
    notifyListeners();

    try {
      final result = await compute(_compressJsonIsolate, _jsonData!);

      if (result.error != null) {
        _setError(result.error!);
        return;
      }

      _recompressedData = result.data!;
      _state = UnzipperState.unzipped;
      _errorMessage = '';
      notifyListeners();

      // Auto-copy to clipboard
      await Clipboard.setData(ClipboardData(text: _recompressedData));
    } catch (e) {
      _setError('Erreur lors de la recompression: ${e.toString()}');
    }
  }

  void reset() {
    _inputData = '';
    _jsonOutput = '';
    _recompressedData = '';
    _errorMessage = '';
    _state = UnzipperState.initial;
    _jsonData = null;
    _isEdited = false;
    notifyListeners();
  }

  // Helper methods
  void _setError(String message) {
    _errorMessage = message;
    _state = UnzipperState.error;
    notifyListeners();
  }

  // Static methods for isolate computation
  static _UnzipResult _unzipDataIsolate(String encoded) {
    try {
      final zipperService = const ZipperService();
      final unzipped = zipperService.unzip(encoded);
      return _UnzipResult(data: unzipped);
    } catch (e) {
      return _UnzipResult(error: 'Erreur de décompression: ${e.toString()}');
    }
  }

  static _ValidationResult _validateJsonIsolate(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return _ValidationResult(data: data);
    } catch (e) {
      return _ValidationResult(error: 'JSON invalide: ${e.toString()}');
    }
  }

  static _CompressionResult _compressJsonIsolate(Map<String, dynamic> json) {
    try {
      final zipperService = const ZipperService();
      final zippedData = zipperService.zip(json);
      return _CompressionResult(data: zippedData);
    } catch (e) {
      return _CompressionResult(error: 'Erreur de compression: ${e.toString()}');
    }
  }
}

// Helper classes for isolate results
class _UnzipResult {
  final Map<String, dynamic>? data;
  final String? error;

  _UnzipResult({this.data, this.error});
}

class _ValidationResult {
  final Map<String, dynamic>? data;
  final String? error;

  _ValidationResult({this.data, this.error});
}

class _CompressionResult {
  final String? data;
  final String? error;

  _CompressionResult({this.data, this.error});
}