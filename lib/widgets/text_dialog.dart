import 'package:canvas_craft/models/text_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextDialog extends StatefulWidget {
  final TextData? textData;
  const TextDialog({super.key, this.textData});

  @override
  State<TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<TextDialog> {
  late TextEditingController _textEditingController;
  late String _displayText;
  late Color _textColor;
  late double _fontSize;
  late double _boxSize;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: widget.textData?.text ?? "");
    _textColor = widget.textData?.textColor ?? Colors.black;
    _fontSize = widget.textData?.fontSize ?? 20.0;
    _boxSize = widget.textData?.boxSize ?? 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Text"),
      content: Column(
        children: [
          TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(label: Text("Enter Text")),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              const Text("Font Size"),
              const SizedBox(width: 10.0),
              Flexible(
                  child: Slider(
                      min: 10.0,
                      max: 50.0,
                      value: _fontSize,
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      })),
              Text(_fontSize.toStringAsFixed(1))
            ],
          ),
          Row(
            children: [
              const Text("Box Size : "),
              const SizedBox(width: 10.0),
              Flexible(
                  child: Slider(
                      min: 50.0,
                      max: 200.0,
                      value: _boxSize,
                      onChanged: (value) {
                        setState(() {
                          _boxSize = value;
                        });
                      })),
              Text(_boxSize.toStringAsFixed(1))
            ],
          ),
          Row(
            children: [
              const Text("Color : "),
              const SizedBox(width: 10.0),
              GestureDetector(
                onTap: () {
                  _showColorPicker();
                },
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                      color: _textColor,
                      border: Border.all(color: Colors.white60, width: 3.0),
                      borderRadius: BorderRadius.circular(25.0)),
                ),
              )
            ],
          )
        ],
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              setState(() {
                _displayText = _textEditingController.text;
              });
              Navigator.of(context).pop(_getTextData());
            },
            child: const Text("Add"))
      ],
    );
  }

  TextData _getTextData() {
    return TextData(
        text: _textEditingController.text,
        position: const Offset(0, 0),
        textColor: _textColor,
        fontSize: _fontSize,
        boxSize: _boxSize);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a color"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _textColor,
              onColorChanged: (Color color) {
                setState(() {
                  _textColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"))
          ],
        );
      },
    );
  }
}
