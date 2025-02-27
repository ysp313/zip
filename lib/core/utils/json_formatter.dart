import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:unzip/core/utils/exceptions.dart';

class JsonFormatter {
  const JsonFormatter._();

  /// Formate une chaîne JSON avec indentation et retours à la ligne
  static String format(String jsonString, {int indent = 2}) {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      return JsonEncoder.withIndent(' ' * indent).convert(decoded);
    } catch (e) {
      throw ValidationException('Format JSON invalide: ${e.toString()}');
    }
  }

  /// Vérifie si une chaîne est du JSON valide
  static bool isValid(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtient une version minifiée (compacte) du JSON
  static String minify(String jsonString) {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      return jsonEncode(decoded);
    } catch (e) {
      throw ValidationException('Format JSON invalide: ${e.toString()}');
    }
  }

  /// Génère un TextSpan avec coloration syntaxique pour affichage
  static TextSpan getSyntaxHighlightedSpan(String jsonString) {
    try {
      // Format JSON string first
      final formattedJson = format(jsonString);

      // Simple syntax highlighting (can be enhanced)
      final List<TextSpan> spans = [];

      // Color definitions
      const keyColor = Color(0xFF9C27B0);    // Purple
      const stringColor = Color(0xFF4CAF50); // Green
      const numberColor = Color(0xFF2196F3); // Blue
      const boolColor = Color(0xFFFF9800);   // Orange
      const nullColor = Color(0xFF9E9E9E);   // Grey
      const symbolColor = Color(0xFF212121); // Dark grey

      // Simple tokenizer for basic syntax highlighting
      final RegExp tokenPattern = RegExp(
        r'("(?:\\.|[^"\\])*")|(-?\d+\.?\d*)|(\btrue\b|\bfalse\b|\bnull\b)|([{}\[\]:,])',
      );

      int lastMatchEnd = 0;

      for (final match in tokenPattern.allMatches(formattedJson)) {
        // Add any non-matched text
        if (match.start > lastMatchEnd) {
          spans.add(TextSpan(
            text: formattedJson.substring(lastMatchEnd, match.start),
          ));
        }

        // Determine token type and add appropriate colored TextSpan
        final String matchText = match.group(0)!;
        if (match.group(1) != null) { // String
          // Check if it's a key (followed by :)
          final isKey = formattedJson.length > match.end + 1 &&
              formattedJson.substring(match.end, match.end + 1).trim() == ':';

          spans.add(TextSpan(
            text: matchText,
            style: TextStyle(
              color: isKey ? keyColor : stringColor,
              fontWeight: isKey ? FontWeight.bold : FontWeight.normal,
            ),
          ));
        } else if (match.group(2) != null) { // Number
          spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(color: numberColor),
          ));
        } else if (match.group(3) != null) { // Boolean or null
          spans.add(TextSpan(
            text: matchText,
            style: TextStyle(
              color: matchText == 'null' ? nullColor : boolColor,
              fontWeight: FontWeight.bold,
            ),
          ));
        } else { // Symbols
          spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(color: symbolColor),
          ));
        }

        lastMatchEnd = match.end;
      }

      // Add any remaining text
      if (lastMatchEnd < formattedJson.length) {
        spans.add(TextSpan(
          text: formattedJson.substring(lastMatchEnd),
        ));
      }

      return TextSpan(
        children: spans,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      );
    } catch (e) {
      // Return plain text on error
      return TextSpan(
        text: jsonString,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.red,
        ),
      );
    }
  }
}