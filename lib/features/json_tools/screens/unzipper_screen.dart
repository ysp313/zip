import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:unzip/features/json_tools/controllers/unzipper_controller.dart';
import 'package:unzip/features/json_tools/widgets/json_editor.dart';
import 'package:flutter/services.dart';

class UnzipperScreen extends StatelessWidget {
  const UnzipperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UnzipperController>(
      create: (_) => UnzipperController(),
      child: const _UnzipperScreenContent(),
    );
  }
}

class _UnzipperScreenContent extends StatelessWidget {
  const _UnzipperScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UnzipperController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Décompression JSON'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: () => controller.reset(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCompressedInputSection(context, controller),
            const SizedBox(height: 16),
            _buildActionButtons(context, controller),
            const SizedBox(height: 16),
            if (controller.state == UnzipperState.error)
              _buildErrorMessage(controller.errorMessage),
            if (controller.state == UnzipperState.unzipped ||
                controller.state == UnzipperState.editing)
              _buildUnzippedOutput(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressedInputSection(BuildContext context, UnzipperController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Données compressées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: controller.setInputData,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Collez ici les données compressées...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UnzipperController controller) {
    return ElevatedButton.icon(
      onPressed: controller.state == UnzipperState.loading
          ? null
          : () => controller.unzipData(),
      icon: const Icon(Icons.file_download),
      label: const Text('Décompresser et afficher'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnzippedOutput(BuildContext context, UnzipperController controller) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'JSON décompressé',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.state == UnzipperState.unzipped)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Éditer',
                          onPressed: controller.startEditing,
                        ),
                        IconButton(
                          icon: const Icon(Icons.file_download),
                          tooltip: 'Télécharger en JSON',
                          onPressed: () => _downloadJson(context, controller),
                        ),
                        IconButton(
                          icon: const Icon(Icons.compress),
                          tooltip: 'Recompresser',
                          onPressed: () => controller.recompressJson(),
                        ),
                      ],
                    )
                  else if (controller.state == UnzipperState.editing)
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Appliquer'),
                          onPressed: controller.applyEdits,
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.cancel),
                          label: const Text('Annuler'),
                          onPressed: controller.stopEditing,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: JsonEditor(
                  initialValue: controller.jsonOutput,
                  onChanged: controller.setJsonOutput,
                  readOnly: controller.state != UnzipperState.editing,
                  enableSyntaxHighlighting: true,
                ),
              ),
              if (controller.recompressedData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Données recompressées',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: controller.recompressedData));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copié dans le presse-papiers'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copier'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: SelectableText(
                          controller.recompressedData,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadJson(BuildContext context, UnzipperController controller) async {
    if (controller.jsonData == null) return;

    try {
      // Convertir les données en JSON formaté
      final String jsonString = const JsonEncoder.withIndent('  ').convert(controller.jsonData);

      // Convertir la chaîne en Uint8List
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      // Générer un nom de fichier avec la date et l'heure actuelles
      final String fileName = 'json_${DateTime.now().millisecondsSinceEpoch}';

      // Sauvegarder le fichier
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );

      // Afficher une confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fichier sauvegardé sous $fileName.json'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}