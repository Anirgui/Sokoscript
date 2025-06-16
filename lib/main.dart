import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const SokoApp());
}

class SokoApp extends StatelessWidget {
  const SokoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soko MGL Script',
      home: const SokoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SokoHomePage extends StatefulWidget {
  const SokoHomePage({super.key});

  @override
  State<SokoHomePage> createState() => _SokoHomePageState();
}

class _SokoHomePageState extends State<SokoHomePage> {
  final GlobalKey _globalKey = GlobalKey();
  String selectedFont = 'Cmdash';
  String userText = 'ᠮᠣᠩᠭᠣᠯ ᠤ ᠪᠢᠴᠢᠭ';
  File? _bgImage;

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _bgImage = File(image.path);
      });
    }
  }

  Future<void> _exportToImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/soko_script.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Амжилттай хадгаллаа: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soko MGL Script'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: _bgImage != null
                      ? DecorationImage(
                          image: FileImage(_bgImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    userText,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: selectedFont,
                      fontSize: 48,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      userText = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Монгол бичиг оруулна уу',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton<String>(
                      value: selectedFont,
                      items: const [
                        DropdownMenuItem(
                          value: 'Cmdash',
                          child: Text('Cmdash фонт'),
                        ),
                        DropdownMenuItem(
                          value: 'MongolScript',
                          child: Text('MongolianScript фонт'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFont = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: _pickBackgroundImage,
                      child: const Text('Арын зураг оруулах'),
                    ),
                    ElevatedButton(
                      onPressed: _exportToImage,
                      child: const Text('Зураг болгох'),
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
