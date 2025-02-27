import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TextCase { upper, lower, title, sentence }

class TextFormatterCubit extends Cubit<String> {
  TextFormatterCubit() : super('');

  void setText(String text) => emit(text);

  void clear() => emit('');

  void convertCase(TextCase textCase) {
    switch (textCase) {
      case TextCase.upper:
        emit(state.toUpperCase());
        break;
      case TextCase.lower:
        emit(state.toLowerCase());
        break;
      case TextCase.title:
        emit(state
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                : '')
            .join(' '));
        break;
      case TextCase.sentence:
        if (state.isEmpty) return;
        final sentences = state.split(RegExp(r'(?<=[.!?])\s+'));
        emit(sentences
            .map((sentence) => sentence.isNotEmpty
                ? sentence[0].toUpperCase() +
                    sentence.substring(1).toLowerCase()
                : '')
            .join(' '));
        break;
    }
  }

  void trimLines() {
    final lines = state.split('\n');
    emit(lines.map((line) => line.trim()).join('\n'));
  }

  void removeEmptyLines() {
    final lines = state.split('\n');
    emit(lines.where((line) => line.trim().isNotEmpty).join('\n'));
  }

  void removeDuplicateLines() {
    final lines = state.split('\n');
    emit(lines.toSet().toList().join('\n'));
  }
}

class TextFormatterScreen extends StatelessWidget {
  const TextFormatterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TextFormatterCubit(),
      child: const _TextFormatterContent(),
    );
  }
}

class _TextFormatterContent extends StatelessWidget {
  const _TextFormatterContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formateur de texte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: () => context.read<TextFormatterCubit>().clear(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(context),
            const SizedBox(height: 16),
            _buildFormatActions(context),
            const SizedBox(height: 16),
            _buildOutputSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Texte à formater',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (text) => context.read<TextFormatterCubit>().setText(text),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Collez ici le texte à formater...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatActions(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions de formatage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<TextFormatterCubit>()
                      .convertCase(TextCase.upper),
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('MAJUSCULES'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<TextFormatterCubit>()
                      .convertCase(TextCase.lower),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('minuscules'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<TextFormatterCubit>()
                      .convertCase(TextCase.title),
                  icon: const Icon(Icons.title),
                  label: const Text('Titre'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<TextFormatterCubit>()
                      .convertCase(TextCase.sentence),
                  icon: const Icon(Icons.short_text),
                  label: const Text('Phrase'),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<TextFormatterCubit>().trimLines(),
                  icon: const Icon(Icons.space_bar),
                  label: const Text('Supprimer espaces'),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<TextFormatterCubit>().removeEmptyLines(),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Supprimer lignes vides'),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<TextFormatterCubit>().removeDuplicateLines(),
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Supprimer doublons'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSection(BuildContext context) {
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
                    'Texte formaté',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copier',
                    onPressed: () async {
                      final text = context.read<TextFormatterCubit>().state;
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Texte copié dans le presse-papiers'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: BlocBuilder<TextFormatterCubit, String>(
                    builder: (context, text) {
                      return SingleChildScrollView(
                        child: SelectableText(
                          text,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      );
                    },
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
