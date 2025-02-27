import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormatterScreen extends StatefulWidget {
  const TextFormatterScreen({super.key});

  @override
  State<TextFormatterScreen> createState() => _TextFormatterScreenState();
}

class _TextFormatterScreenState extends State<TextFormatterScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  TextCase _selectedCase = TextCase.none;
  bool _trimWhitespace = true;
  bool _removeExtraSpaces = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _processText() {
    String result = _inputController.text;

    // Appliquer les transformations
    if (_trimWhitespace) {
      result = result.trim();
    }

    if (_removeExtraSpaces) {
      result = result.replaceAll(RegExp(r'\s+'), ' ');
    }

    switch (_selectedCase) {
      case TextCase.upper:
        result = result.toUpperCase();
        break;
      case TextCase.lower:
        result = result.toLowerCase();
        break;
      case TextCase.capitalize:
        result = _capitalizeEachWord(result);
        break;
      case TextCase.sentence:
        result = _capitalizeSentences(result);
        break;
      case TextCase.none:
      // Ne rien faire
        break;
    }

    _outputController.text = result;
  }

  String _capitalizeEachWord(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _capitalizeSentences(String text) {
    if (text.isEmpty) return text;

    // Diviser en phrases (en utilisant ., !, ? comme délimiteurs)
    final RegExp sentenceDelimiter = RegExp(r'(\.|\!|\?)\s*');
    final List<String> sentences = text.split(sentenceDelimiter);

    // Capitaliser chaque phrase
    String result = '';
    for (int i = 0; i < sentences.length; i++) {
      if (sentences[i].isEmpty) continue;

      // Capitaliser la première lettre de la phrase
      String sentence = sentences[i].trim();
      if (sentence.isNotEmpty) {
        sentence = sentence[0].toUpperCase() + sentence.substring(1);
      }

      result += sentence;

      // Ajouter le délimiteur s'il y en a un (sauf pour la dernière phrase)
      if (i < sentences.length - 1 && text.contains(sentenceDelimiter)) {
        result += '. ';
      }
    }

    return result;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _outputController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texte copié dans le presse-papiers'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearText() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formateur de texte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: _clearText,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildOptionsSection(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildOutputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Texte d\'entrée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Saisissez ou collez votre texte ici...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options de formatage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Casse: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<TextCase>(
                    isExpanded: true,
                    value: _selectedCase,
                    onChanged: (TextCase? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCase = newValue;
                        });
                      }
                    },
                    items: TextCase.values.map((TextCase textCase) {
                      return DropdownMenuItem<TextCase>(
                        value: textCase,
                        child: Text(textCase.displayName),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Supprimer les espaces au début et à la fin'),
              value: _trimWhitespace,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    _trimWhitespace = value;
                  });
                }
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Supprimer les espaces multiples'),
              value: _removeExtraSpaces,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    _removeExtraSpaces = value;
                  });
                }
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton(
      onPressed: _processText,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('Formater le texte'),
    );
  }

  Widget _buildOutputSection() {
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
                    tooltip: 'Copier dans le presse-papiers',
                    onPressed: _outputController.text.isNotEmpty
                        ? _copyToClipboard
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: _outputController,
                    maxLines: null,
                    readOnly: true,
                    expands: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Le texte formaté apparaîtra ici...',
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

enum TextCase {
  none,
  upper,
  lower,
  capitalize,
  sentence;

  String get displayName {
    switch (this) {
      case TextCase.none:
        return 'Aucun changement';
      case TextCase.upper:
        return 'MAJUSCULES';
      case TextCase.lower:
        return 'minuscules';
      case TextCase.capitalize:
        return 'Capitaliser Chaque Mot';
      case TextCase.sentence:
        return 'Capitaliser les phrases';
    }
  }
}