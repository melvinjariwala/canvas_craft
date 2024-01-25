import 'package:canvas_craft/models/text_data.dart';
import 'package:canvas_craft/widgets/text_dialog.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class EditingScreen extends StatefulWidget {
  const EditingScreen({super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  List<TextData> textDataList = [];
  int selectedTextIndex = -1;
  List<List<TextData>> undoStack = [];
  List<List<TextData>> redoStack = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Canvas Craft"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              if (selectedTextIndex != -1) {
                setState(() {
                  textDataList[selectedTextIndex].position += details.delta;
                  _addUndoSnapshot();
                });
              }
            },
            child: PhotoViewGallery.builder(
              itemCount: 1,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                    imageProvider: const AssetImage('assets/blank.jpg'),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3);
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
          ...textDataList.asMap().entries.map((entry) {
            int index = entry.key;
            TextData textData = entry.value;
            return Positioned(
                left: textData.position.dx,
                top: textData.position.dy,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTextIndex = index;
                    });
                  },
                  onDoubleTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => TextDialog(textData: textData),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          textDataList[index] = value;
                          _addUndoSnapshot();
                        });
                      }
                    });
                  },
                  child: SizedBox(
                    width: textData.boxSize,
                    height: textData.boxSize,
                    child: Text(
                      textData.text,
                      style: TextStyle(
                          color: textData.textColor,
                          fontSize: textData.fontSize),
                    ),
                  ),
                ));
          }).toList()
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (undoStack.isNotEmpty) {
                      setState(() {
                        redoStack.add(List.from(textDataList));
                        textDataList = List.from(undoStack.removeLast());
                      });
                    }
                  },
                  tooltip: "Undo",
                  child: const Icon(Icons.undo),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    if (redoStack.isNotEmpty) {
                      setState(() {
                        undoStack.add(List.from(textDataList));
                        textDataList = List.from(redoStack.removeLast());
                      });
                    }
                  },
                  tooltip: "Redo",
                  child: const Icon(Icons.redo),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => const TextDialog()).then((value) {
                      if (value != null) {
                        setState(() {
                          textDataList.add(value);
                          _addUndoSnapshot();
                        });
                      }
                    });
                  },
                  child: const Icon(Icons.text_fields),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _addUndoSnapshot() {
    undoStack
        .add(List.from(textDataList.map((textData) => textData.snapshot())));
  }
}
