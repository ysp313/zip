import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:unzip/core/utils/exceptions.dart';

class ZipperService {
  const ZipperService();

  /// Compresse des données JSON
  ///
  /// Retourne une chaîne contenant les données compressées
  /// Lève une [ZipperException] en cas d'erreur
  String zip(Map<String, dynamic> json) {
    try {
      // Convertir le JSON en chaîne
      final jsonStr = jsonEncode(json);

      // Encoder en UTF-8
      final bytes = utf8.encode(jsonStr);

      // Compresser avec GZip
      final gzipped = GZipEncoder().encode(bytes);
      if (gzipped == null) {
        throw ZipperException('Échec de la compression GZip');
      }

      // Encoder en JSON pour transport
      return jsonEncode(gzipped);
    } catch (e) {
      if (e is ZipperException) rethrow;
      throw ZipperException('Erreur lors de la compression', e);
    }
  }

  /// Décompresse une chaîne compressée en JSON
  ///
  /// Retourne un Map contenant les données JSON décompressées
  /// Lève une [ZipperException] en cas d'erreur
  Map<String, dynamic> unzip(String encoded) {
    try {
      // Décoder la chaîne en liste d'entiers
      final bytes = (jsonDecode(encoded) as List).cast<int>();

      // Décompresser avec GZip
      final gUnzipped = GZipDecoder().decodeBytes(bytes);

      // Décoder en UTF-8
      final jsonStr = utf8.decode(gUnzipped);

      // Convertir en Map JSON
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      throw ZipperException('Erreur lors de la décompression', e);
    }
  }

  /// Vérifie si une chaîne est du JSON valide
  ///
  /// Retourne true si le JSON est valide, false sinon
  bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valide et formate du JSON
  ///
  /// Retourne une chaîne JSON formatée
  /// Lève une [ZipperException] en cas d'erreur
  String formatJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      throw ZipperException('JSON invalide', e);
    }
  }
}