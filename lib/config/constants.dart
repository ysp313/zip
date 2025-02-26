import 'package:flutter/material.dart';
import 'package:unzip/config/routes.dart';
import 'package:unzip/core/models/tool.dart';

class AppConstants {
  // Taille maximale de fichier supportée en octets (10 MB)
  static const int maxFileSize = 10 * 1024 * 1024;

  // Catégories d'outils disponibles
  static final List<ToolCategory> toolCategories = [
    const ToolCategory(
      id: 'json_tools',
      title: 'Outils JSON',
      icon: Icons.data_object,
      tools: [
        Tool(
          id: 'json_zipper',
          title: 'Compression JSON',
          description: 'Compresser des données JSON pour un stockage efficace',
          icon: Icons.file_upload,
          color: Colors.blue,
          routeName: AppRoutes.zipper,
          tags: ['json', 'compression', 'stockage'],
        ),
        Tool(
          id: 'json_unzipper',
          title: 'Décompression JSON',
          description: 'Décompresser des données JSON compressées',
          icon: Icons.file_download,
          color: Colors.green,
          routeName: AppRoutes.unzipper,
          tags: ['json', 'décompression', 'visualisation'],
        ),
      ],
    ),
    const ToolCategory(
      id: 'text_tools',
      title: 'Outils Texte',
      icon: Icons.text_fields,
      tools: [
        Tool(
          id: 'text_formatter',
          title: 'Formateur de texte',
          description: 'Formatter et transformer du texte',
          icon: Icons.format_align_left,
          color: Colors.purple,
          routeName: AppRoutes.textFormatter,
          tags: ['texte', 'formatter', 'transformer'],
        ),
      ],
    ),
  ];
}