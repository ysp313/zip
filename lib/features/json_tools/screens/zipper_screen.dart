import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unzip/config/constants.dart';
import 'package:unzip/features/json_tools/cubits/zipper_cubit.dart';
import 'package:unzip/features/json_tools/widgets/json_editor.dart';
import 'package:unzip/features/json_tools/widgets/file_operation_buttons.dart';
import 'package:flutter/services.dart';

class ZipperScreen extends StatelessWidget {
  const ZipperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZipperCubit>(
      create: (_) => ZipperCubit(),
      child: const _ZipperScreenContent(),
    );
  }
}

class _ZipperScreenContent extends StatelessWidget {
  const _ZipperScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compression JSON'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: () => context.read<ZipperCubit>().reset(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFileInputSection(context),
            const SizedBox(height: 16),
            _buildJsonInputSection(context),
            const SizedBox(height: 16),
            _buildActionButtons(context),
            const SizedBox(height: 16),
            BlocBuilder<ZipperCubit, ZipperState>(
              builder: (context, state) {
                if (state.status == ZipperStatus.error) {
                  return _buildErrorMessage(state.errorMessage);
                }
                if (state.status == ZipperStatus.compressed) {
                  return _buildCompressedOutput(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInputSection(BuildContext context) {
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
                context.read<ZipperCubit>().setJsonInput(content);
                context.read<ZipperCubit>().validateJson();
              },
              allowedExtensions: const ['json'],
              maxFileSize: AppConstants.maxFileSize,
            ),
            BlocBuilder<ZipperCubit, ZipperState>(
              builder: (context, state) {
                if (state.isFileLoaded && state.fileName != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Fichier chargé: ${state.fileName}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonInputSection(BuildContext context) {
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
                child: BlocBuilder<ZipperCubit, ZipperState>(
                  builder: (context, state) {
                    return JsonEditor(
                      initialValue: state.jsonInput,
                      onChanged: (value) =>
                          context.read<ZipperCubit>().setJsonInput(value),
                      readOnly: state.status == ZipperStatus.loading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<ZipperCubit, ZipperState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: state.status == ZipperStatus.loading
                    ? null
                    : () => context.read<ZipperCubit>().validateJson(),
                icon: const Icon(Icons.check_circle),
                label: const Text('Valider le JSON'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: state.status == ZipperStatus.validated ||
                        state.status == ZipperStatus.compressed
                    ? () => context.read<ZipperCubit>().compressData()
                    : null,
                icon: const Icon(Icons.compress),
                label: const Text('Compresser'),
              ),
            ),
          ],
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

  Widget _buildCompressedOutput(BuildContext context, ZipperState state) {
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
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: state.compressedData));
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
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: SelectableText(
                      state.compressedData,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
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
