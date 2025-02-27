import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultDisplay extends StatelessWidget {
  final String data;
  final String title;
  final VoidCallback? onCopy;
  final VoidCallback? onDownload;
  final bool isMonospace;
  final Color? backgroundColor;

  const ResultDisplay({
    super.key,
    required this.data,
    required this.title,
    this.onCopy,
    this.onDownload,
    this.isMonospace = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                data,
                style: TextStyle(
                  fontFamily: isMonospace ? 'monospace' : null,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copier dans le presse-papiers',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copié dans le presse-papiers'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    if (onCopy != null) onCopy!();
                  },
                ),
              if (onDownload != null)
                IconButton(
                  icon: const Icon(Icons.download, size: 20),
                  tooltip: 'Télécharger',
                  onPressed: onDownload,
                ),
            ],
          ),
        ],
      ),
    );
  }
}