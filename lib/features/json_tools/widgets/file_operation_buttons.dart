import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

typedef FileContentCallback = void Function(String content);

class FileOperationButtons extends StatelessWidget {
  final FileContentCallback onFilePicked;
  final List<String> allowedExtensions;
  final int maxFileSize;

  const FileOperationButtons({
    super.key,
    required this.onFilePicked,
    required this.allowedExtensions,
    required this.maxFileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickFile(context),
            icon: const Icon(Icons.upload_file),
            label: const Text('Choisir un fichier'),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => _showPasteDialog(context),
          icon: const Icon(Icons.paste),
          label: const Text('Coller depuis le presse-papier'),
        ),
      ],
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) {
        return; // Annulé par l'utilisateur
      }

      final file = result.files.first;

      // Vérifier la taille du fichier
      if (file.size > maxFileSize) {
        if (context.mounted) {
          _showErrorDialog(context, 'Taille de fichier excessive',
              'Le fichier sélectionné dépasse la taille maximale autorisée (${maxFileSize ~/ 1024 ~/ 1024} MB).');
        }
        return;
      }

      // Lire le contenu du fichier
      if (file.bytes != null) {
        final content = utf8.decode(file.bytes!);
        onFilePicked(content);
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Erreur de lecture',
              'Impossible de lire le contenu du fichier.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Erreur',
            'Une erreur s\'est produite lors de la sélection du fichier: ${e.toString()}');
      }
    }
  }

  Future<void> _showPasteDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coller du texte'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Collez votre texte ici...',
            ),
            maxLines: 10,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Valider'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onFilePicked(controller.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
