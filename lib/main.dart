import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unzip/zipper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestionnaire de Compression',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DataCompressorTabs(),
    );
  }
}

class DataCompressorTabs extends StatefulWidget {
  const DataCompressorTabs({super.key});

  @override
  State<DataCompressorTabs> createState() => _DataCompressorTabsState();
}

class _DataCompressorTabsState extends State<DataCompressorTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionnaire de Compression'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.file_download), text: 'Décompresser'),
            Tab(icon: Icon(Icons.file_upload), text: 'Compresser'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UnzipperTab(),
          ZipperTab(),
        ],
      ),
    );
  }
}

class UnzipperTab extends StatefulWidget {
  const UnzipperTab({super.key});

  @override
  State<UnzipperTab> createState() => _UnzipperTabState();
}

class _UnzipperTabState extends State<UnzipperTab> {
  Map<String, dynamic>? _unzippedData;
  String? _error;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _jsonEditController = TextEditingController();
  bool _isEditing = false;

  void _processData() {
    setState(() {
      try {
        _unzippedData = Zipper.unzip(_inputController.text);
        _error = null;
        // Préparer le contenu pour l'édition éventuelle
        _jsonEditController.text = const JsonEncoder.withIndent('  ').convert(_unzippedData);
      } catch (e) {
        _error = 'Erreur lors de la décompression: ${e.toString()}';
        _unzippedData = null;
        _jsonEditController.text = '';
      }
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _applyJsonEdits() {
    try {
      // Convertir le texte édité en Map
      final Map<String, dynamic> editedData = jsonDecode(_jsonEditController.text) as Map<String, dynamic>;
      setState(() {
        _unzippedData = editedData;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modifications appliquées avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur dans le JSON: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _recompressJson() async {
    if (_unzippedData != null) {
      try {
        // Utiliser la méthode zip de la classe Zipper
        final String? zippedData = Zipper.zip(_unzippedData!);

        if (zippedData != null) {
          // Copier dans le presse-papier
          await Clipboard.setData(ClipboardData(text: zippedData));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Données recompressées copiées dans le presse-papier'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Échec de la compression : résultat null"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la recompression: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadJson() async {
    if (_unzippedData != null) {
      try {
        // Convertir les données en JSON formaté
        final String jsonString =
        const JsonEncoder.withIndent('  ').convert(_unzippedData);

        // Convertir la chaîne en Uint8List
        final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

        // Générer un nom de fichier avec la date et l'heure actuelles
        final String fileName = 'data_${DateTime.now().millisecondsSinceEpoch}';

        // Sauvegarder le fichier
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: 'json',
          mimeType: MimeType.json,
        );

        // Afficher une confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fichier sauvegardé sous $fileName.json'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
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

  @override
  void dispose() {
    _inputController.dispose();
    _jsonEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Collez les données compressées ici',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _processData,
            child: const Text('Décompresser et afficher'),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          if (_unzippedData != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Données décompressées :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _toggleEditMode,
                  icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
                  label: Text(_isEditing ? 'Voir' : 'Éditer'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _isEditing
                      ? TextField(
                    controller: _jsonEditController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Éditez le JSON ici',
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                  )
                      : Text(
                    const JsonEncoder.withIndent('  ').convert(_unzippedData),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _unzippedData != null ? _downloadJson : null,
                    child: const Text('Télécharger en JSON'),
                  ),
                ),
                const SizedBox(width: 8),
                if (_isEditing)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyJsonEdits,
                      child: const Text('Appliquer les modifications'),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _unzippedData != null ? _recompressJson : null,
                      child: const Text('Recompresser et copier'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ZipperTab extends StatefulWidget {
  const ZipperTab({super.key});

  @override
  State<ZipperTab> createState() => _ZipperTabState();
}

class _ZipperTabState extends State<ZipperTab> {
  final TextEditingController _jsonController = TextEditingController();
  String? _compressedData;
  String? _error;
  Map<String, dynamic>? _jsonData;
  bool _isFileLoaded = false;
  String? _fileName;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _pickJsonFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final bytes = result.files.single.bytes;
        if (bytes != null) {
          final jsonStr = utf8.decode(bytes);

          // Essayer de parser le JSON pour vérifier sa validité
          try {
            final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
            setState(() {
              _jsonController.text = const JsonEncoder.withIndent('  ').convert(jsonData);
              _jsonData = jsonData;
              _isFileLoaded = true;
              _fileName = result.files.single.name;
              _error = null;
              _compressedData = null;
            });
          } catch (e) {
            setState(() {
              _error = 'Fichier JSON invalide: ${e.toString()}';
              _isFileLoaded = false;
              _jsonData = null;
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la sélection du fichier: ${e.toString()}';
      });
    }
  }

  void _processJsonText() {
    try {
      final jsonData = jsonDecode(_jsonController.text) as Map<String, dynamic>;
      setState(() {
        _jsonData = jsonData;
        _error = null;
        _compressedData = null;
      });
    } catch (e) {
      setState(() {
        _error = 'JSON invalide: ${e.toString()}';
        _jsonData = null;
      });
    }
  }

  void _compressData() {
    if (_jsonData != null) {
      try {
        final String? zippedData = Zipper.zip(_jsonData!);
        setState(() {
          _compressedData = zippedData;
          _error = null;
        });
      } catch (e) {
        setState(() {
          _error = 'Erreur lors de la compression: ${e.toString()}';
          _compressedData = null;
        });
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_compressedData != null) {
      await Clipboard.setData(ClipboardData(text: _compressedData!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données compressées copiées dans le presse-papier'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _pickJsonFile,
            icon: const Icon(Icons.file_open),
            label: const Text('Choisir un fichier JSON'),
          ),
          if (_isFileLoaded && _fileName != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Fichier chargé: $_fileName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Ou collez/éditez le JSON directement:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3, // Donnez plus d'espace au champ de texte pour le JSON
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'JSON à compresser',
                border: OutlineInputBorder(),
                hintText: '{"exemple": "données JSON"}',
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _processJsonText,
                  child: const Text('Valider le JSON'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _jsonData != null ? _compressData : null,
                  child: const Text('Compresser'),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (_compressedData != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Données compressées:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2, // Donnez de l'espace pour les données compressées
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[200],
                  ),
                  child: SelectableText(
                    _compressedData!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _compressedData != null ? _copyToClipboard : null,
              icon: const Icon(Icons.copy),
              label: const Text('Copier dans le presse-papier'),
            ),
          ],
        ],
      ),
    );
  }
}