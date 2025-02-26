import 'dart:convert';

import 'package:archive/archive.dart';

class Zipper {
  const Zipper._();
  static String? zip(Map<String, dynamic> json) {
    final jsonStr = jsonEncode(json);
    final bytes = utf8.encode(jsonStr);
    final gzipped = GZipEncoder().encode(bytes);
    return jsonEncode(gzipped);

  }

  static Map<String, dynamic>? unzip(String encoded) {
    final bytes = (jsonDecode(encoded) as List).cast<int>();
    final gUnzipped = GZipDecoder().decodeBytes(bytes);
    final jsonStr = utf8.decode(gUnzipped);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}
