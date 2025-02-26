import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:unzip/config/constants.dart';
import 'package:unzip/features/json_tools/controllers/zipper_controller.dart';
import 'package:unzip/features/json_tools/widgets/json_editor.dart';
import 'package:unzip/features/json_tools/widgets/file_operation_buttons.dart';
import 'package:flutter/services.dart';

class ZipperScreen extends StatelessWidget {
  const ZipperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ZipperController>(
      create: (_) => ZipperController(),
      child: const _ZipperScreenContent(),
    );
  }
}

class _ZipperScreenContent extends StatelessWidget {
  const _ZipperScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ZipperController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compression JSON'),
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
            _buildFileInputSection(context, controller),
            const SizedBox(height: 16),
            _buildJsonInputSection(context, controller),
            const SizedBox(height: 16),
            _buildActionButtons(context, controller),
            const SizedBox(height: 16),
            if (controller.state == ZipperState.error)
              _buildErrorMessage(controller.errorMessage),
            if (controller.state == ZipperState.compressed)
              _buildCompressedOutput(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInputSection(BuildContext context, ZipperController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Importer un fichier JSON',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FileOperationButtons(
              onFilePicked: (content) async {
                controller.setJsonInput(content);
                controller.validateJson();
              },
              allowedExtensions: ['json'],
              maxFileSize: AppConstants.maxFileSize,
            ),
            if (controller.isFileLoaded && controller.fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Fichier chargé: ${controller.fileName}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonInputSection(BuildContext context, ZipperController controller) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'JSON à compresser',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: JsonEditor(
                  initialValue: controller.jsonInput,
                  onChanged: controller.setJsonInput,
                  readOnly: controller.state == ZipperState.loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ZipperController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.state == ZipperState.loading
                ? null
                : () => controller.validateJson(),
            icon: const Icon(Icons.check_circle),
            label: const Text('Valider le JSON'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.state == ZipperState.validated ||
                controller.state == ZipperState.compressed
                ? () => controller.compressData()
                : null,
            icon: const Icon(Icons.compress),
            label: const Text('Compresser'),
          ),
        ),
      ],
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

  Widget _buildCompressedOutput(BuildContext context, ZipperController controller) {
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
                    'Données compressées',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.copyToClipboard();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copié dans le presse-papiers'),
                          backgroundColor: Colors.green,
                        ),
                      );
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      controller.compressedData,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}