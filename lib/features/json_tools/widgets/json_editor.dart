import 'package:flutter/material.dart';
import 'package:unzip/core/utils/json_formatter.dart';

class JsonEditor extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final bool enableSyntaxHighlighting;
  final double fontSize;
  final int maxLines;

  const JsonEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.readOnly = false,
    this.enableSyntaxHighlighting = true,
    this.fontSize = 14.0,
    this.maxLines = 20,
  });

  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    // Validate initial JSON
    _isValid = JsonFormatter.isValid(widget.initialValue);

    // Listen for changes
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(JsonEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the controller text if the initialValue changes from outside
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
      _isValid = JsonFormatter.isValid(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    // Notify parent of changes
    widget.onChanged(_controller.text);

    // Check if JSON is valid (but not on every keystroke to avoid performance issues)
    if (_controller.text.length % 5 == 0) {
      setState(() {
        _isValid = JsonFormatter.isValid(_controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _isValid ? Colors.grey : Colors.red,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // The actual editor
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: widget.enableSyntaxHighlighting && widget.readOnly
                ? _buildSyntaxHighlightedView()
                : _buildEditableTextField(),
          ),

          // JSON validation indicator
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isValid ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyntaxHighlightedView() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: RichText(
        text: JsonFormatter.getSyntaxHighlightedSpan(_controller.text),
      ),
    );
  }

  Widget _buildEditableTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      scrollController: _scrollController,
      maxLines: widget.maxLines,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(16),
        border: InputBorder.none,
        hintText: 'Entrez ou modifiez le JSON ici...',
      ),
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: widget.fontSize,
      ),
      readOnly: widget.readOnly,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}