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
  String _selectedFont = "Default";

  static const List<String> fontStyles = [
    "Default",
    "Arial",
    "Times New Roman",
    "Courier New",
    "Georgia"
  ];

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: widget.textData?.text ?? "");
    _textColor = widget.textData?.textColor ?? Colors.black;
    _fontSize = widget.textData?.fontSize ?? 20.0;
    _boxSize = widget.textData?.boxSize ?? 100.0;
    _selectedFont = widget.textData?.fontStyle ?? "Default";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Add Text",
        style: TextStyle(
            color: Color.fromARGB(255, 0, 97, 81), fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
                label: const Text("Enter Text"),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0))),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              const Text("Font Style : "),
              const SizedBox(width: 10.0),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                        color: const Color.fromARGB(255, 0, 97, 81))),
                padding: const EdgeInsets.fromLTRB(7.0, 0, 0, 0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                      borderRadius: BorderRadius.circular(25.0),
                      value: _selectedFont,
                      items: fontStyles
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedFont = value!;
                        });
                      }),
                ),
              )
            ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      elevation: 10.0,
    );
  }

  TextData _getTextData() {
    return TextData(
        text: _textEditingController.text,
        position: const Offset(0, 0),
        textColor: _textColor,
        fontSize: _fontSize,
        boxSize: _boxSize,
        fontStyle: _selectedFont);
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
