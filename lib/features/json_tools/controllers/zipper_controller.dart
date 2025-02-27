import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unzip/core/services/zipper_service.dart';

enum ZipperState {
  initial,
  loading,
  validated,
  compressed,
  error,
}

class ZipperController extends ChangeNotifier {
  String _jsonInput = '';
  String _compressedData = '';
  String _errorMessage = '';
  ZipperState _state = ZipperState.initial;
  Map<String, dynamic>? _jsonData;
  bool _isFileLoaded = false;
  String? _fileName;

  // Getters
  String get jsonInput => _jsonInput;
  String get compressedData => _compressedData;
  String get errorMessage => _errorMessage;
  ZipperState get state => _state;
  bool get isFileLoaded => _isFileLoaded;
  String? get fileName => _fileName;

  // Setters
  void setJsonInput(String value) {
    _jsonInput = value;
    // Reset state if we're in error or compressed state
    if (_state == ZipperState.error || _state == ZipperState.compressed) {
      _state = ZipperState.initial;
    }
    notifyListeners();
  }

  void setFileName(String? name) {
    _fileName = name;
    notifyListeners();
  }

  void setFileLoaded(bool value) {
    _isFileLoaded = value;
    notifyListeners();
  }

  // Action methods
  Future<void> validateJson() async {
    if (_jsonInput.trim().isEmpty) {
      _setError('Veuillez entrer des données JSON');
      return;
    }

    _state = ZipperState.loading;
    notifyListeners();

    try {
      // Use compute to run the validation in a separate isolate for large JSON
      final result = await compute(_validateJsonIsolate, _jsonInput);

      if (result.error != null) {
        _setError(result.error!);
        return;
      }

      _jsonData = result.data;
      _state = ZipperState.validated;
      _errorMessage = '';

      // Format the JSON input to make it more readable
      _jsonInput = const JsonEncoder.withIndent('  ').convert(_jsonData);

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la validation: ${e.toString()}');
    }
  }

  Future<void> compressData() async {
    if (_jsonData == null) {
      await validateJson();

      if (_state != ZipperState.validated) {
        return; // Validation failed
      }
    }

    _state = ZipperState.loading;
    notifyListeners();

    try {
      final result = await compute(
        _compressJsonIsolate,
        _jsonData!,
      );

      if (result.error != null) {
        _setError(result.error!);
        return;
      }

      _compressedData = result.data!;
      _state = ZipperState.compressed;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la compression: ${e.toString()}');
    }
  }

  Future<void> copyToClipboard() async {
    if (_compressedData.isEmpty) {
      _setError('Aucune donnée à copier');
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: _compressedData));
    } catch (e) {
      _setError('Erreur lors de la copie: ${e.toString()}');
    }
  }

  void reset() {
    _jsonInput = '';
    _compressedData = '';
    _errorMessage = '';
    _state = ZipperState.initial;
    _jsonData = null;
    _isFileLoaded = false;
    _fileName = null;
    notifyListeners();
  }

  // Helper methods
  void _setError(String message) {
    _errorMessage = message;
    _state = ZipperState.error;
    notifyListeners();
  }

  // Static methods for isolate computation
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
      const zipperService = ZipperService();
      final zippedData = zipperService.zip(json);
      return _CompressionResult(data: zippedData);
    } catch (e) {
      return _CompressionResult(
          error: 'Erreur de compression: ${e.toString()}');
    }
  }
}

// Helper classes for isolate results
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
