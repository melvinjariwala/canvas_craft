import 'dart:convert';

import 'package:canvas_craft/models/text_data.dart';
import 'package:canvas_craft/widgets/text_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;

class EditingScreen extends StatefulWidget {
  const EditingScreen({super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final GlobalKey _globalKey = GlobalKey();
  List<TextData> textDataList = [];
  int selectedTextIndex = -1;
  List<List<TextData>> undoStack = [];
  List<List<TextData>> redoStack = [];

  Future<Uint8List?> _capturePng() async {
    try {
      print("_globalKey.currentContext : ${_globalKey.currentContext}");
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      print("Before toImage");

      if (boundary.debugNeedsPaint) {
        print("Waiting for boundary to be painted.");
        await Future.delayed(const Duration(milliseconds: 20));
        return _capturePng();
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      print("After toImage");
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _exportImage() async {
    Uint8List? pngBytes = await _capturePng();
    if (pngBytes != null) {
      final result =
          await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes));
      if (result != null) {
        Fluttertoast.showToast(
            msg: "Image Saved Successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "Failed to show image!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Canvas Craft"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _exportImage();
              },
              tooltip: "Export Image",
              icon: const Icon(Icons.save))
        ],
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
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
            ...textDataList.asMap().entries.map((entry) {
              int index = entry.key;
              TextData textData = entry.value;
              return Positioned(
                  left: textData.position.dx,
                  top: textData.position.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (selectedTextIndex != -1) {
                        setState(() {
                          textDataList[selectedTextIndex].position +=
                              details.delta;
                          _addUndoSnapshot();
                        });
                      }
                    },
                    onTap: () {
                      setState(() {
                        selectedTextIndex = index;
                      });
                    },
                    onDoubleTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            TextDialog(textData: textData),
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
                            fontSize: textData.fontSize,
                            fontFamily: textData.fontStyle != "Default"
                                ? textData.fontStyle
                                : null),
                      ),
                    ),
                  ));
            }).toList()
          ],
        ),
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
                    _performUndo();
                  },
                  tooltip: "Undo",
                  child: const Icon(Icons.undo),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    _performRedo();
                  },
                  tooltip: "Redo",
                  child: const Icon(Icons.redo),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            const TextDialog()).then((value) {
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

  void _performRedo() {
    if (redoStack.isNotEmpty) {
      setState(() {
        undoStack.add(List.from(textDataList));
        textDataList = List.from(redoStack.removeLast());
      });
    }
  }

  void _performUndo() {
    if (undoStack.isNotEmpty) {
      setState(() {
        redoStack.add(List.from(textDataList));
        textDataList = List.from(undoStack.removeLast());
      });
    }
  }

  void _addUndoSnapshot() {
    undoStack
        .add(List.from(textDataList.map((textData) => textData.snapshot())));
  }
}
