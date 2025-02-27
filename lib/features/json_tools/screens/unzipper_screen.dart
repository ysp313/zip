import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unzip/features/json_tools/cubits/unzipper_cubit.dart';
import 'package:unzip/features/json_tools/widgets/json_editor.dart';
import 'package:flutter/services.dart';

class UnzipperScreen extends StatelessWidget {
  const UnzipperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UnzipperCubit>(
      create: (_) => UnzipperCubit(),
      child: const _UnzipperScreenContent(),
    );
  }
}

class _UnzipperScreenContent extends StatelessWidget {
  const _UnzipperScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Décompression JSON'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: () => context.read<UnzipperCubit>().reset(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCompressedInputSection(context),
            const SizedBox(height: 16),
            _buildActionButtons(context),
            const SizedBox(height: 16),
            BlocBuilder<UnzipperCubit, UnzipperState>(
              builder: (context, state) {
                if (state.status == UnzipperStatus.error) {
                  return _buildErrorMessage(state.errorMessage);
                }
                if (state.status == UnzipperStatus.unzipped ||
                    state.status == UnzipperStatus.editing) {
                  return _buildUnzippedOutput(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressedInputSection(BuildContext context) {
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
              onChanged: (value) => context.read<UnzipperCubit>().setInputData(value),
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

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<UnzipperCubit, UnzipperState>(
      builder: (context, state) {
        return ElevatedButton.icon(
          onPressed: state.status == UnzipperStatus.loading
              ? null
              : () => context.read<UnzipperCubit>().unzipData(),
          icon: const Icon(Icons.file_download),
          label: const Text('Décompresser et afficher'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
      },
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

  Widget _buildUnzippedOutput(BuildContext context, UnzipperState state) {
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
                  if (state.status == UnzipperStatus.unzipped)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Éditer',
                          onPressed: () => context.read<UnzipperCubit>().startEditing(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.file_download),
                          tooltip: 'Télécharger en JSON',
                          onPressed: () => _downloadJson(context, state),
                        ),
                        IconButton(
                          icon: const Icon(Icons.compress),
                          tooltip: 'Recompresser',
                          onPressed: () => context.read<UnzipperCubit>().recompressJson(),
                        ),
                      ],
                    )
                  else if (state.status == UnzipperStatus.editing)
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Appliquer'),
                          onPressed: () => context.read<UnzipperCubit>().applyEdits(),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.cancel),
                          label: const Text('Annuler'),
                          onPressed: () => context.read<UnzipperCubit>().stopEditing(),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: JsonEditor(
                  initialValue: state.jsonOutput,
                  onChanged: (value) => context.read<UnzipperCubit>().setJsonOutput(value),
                  readOnly: state.status != UnzipperStatus.editing,
                  enableSyntaxHighlighting: true,
                ),
              ),
              if (state.recompressedData.isNotEmpty)
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
                              await Clipboard.setData(ClipboardData(text: state.recompressedData));
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
                          state.recompressedData,
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

  Future<void> _downloadJson(BuildContext context, UnzipperState state) async {
    if (state.jsonData == null) return;

    try {
      final String jsonString = const JsonEncoder.withIndent('  ').convert(state.jsonData);
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
      final String fileName = 'json_${DateTime.now().millisecondsSinceEpoch}';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );

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