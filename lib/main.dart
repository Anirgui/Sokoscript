import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(SokoMglScriptApp());
}

class SokoMglScriptApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soko MGL Script',
      home: ScriptEditorPage(),
    );
  }
}

class ScriptEditorPage extends StatefulWidget {
  @override
  _ScriptEditorPageState createState() => _ScriptEditorPageState();
}

class _ScriptEditorPageState extends State<ScriptEditorPage> {
  final TextEditingController _controller = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String _selectedFontFamily = 'MongolianScript';
  File? _backgroundImage;

  List<String> _fonts = ['MongolianScript', 'CmdAshitseden'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveAsImage() async {
    final imageBytes = await _screenshotController.capture();
    if (imageBytes == null) return;

    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/mongolian_script_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Зураг хадгалагдлаа: $path')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soko MGL Script'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: _backgroundImage != null
                      ? DecorationImage(
                          image: FileImage(_backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _controller.text,
                  style: TextStyle(
                    fontFamily: _selectedFontFamily,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Монгол бичгийн текст'),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedFontFamily,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFontFamily = newValue!;
                    });
                  },
                  items: _fonts.map((font) {
                    return DropdownMenuItem(
                      value: font,
                      child: Text(font),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Арын зураг сонгох'),
                    ),
                    ElevatedButton(
                      onPressed: _saveAsImage,
                      child: Text('Зураг болгох'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
