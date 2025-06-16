import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soko MGL Script',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFont = 'MongolianScript';
  String text = 'ᠮᠣᠩᠭᠣᠯ ᠪᠢᠴᠢᠭ';
  File? backgroundImage;
  ScreenshotController screenshotController = ScreenshotController();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        backgroundImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveImage() async {
    final image = await screenshotController.capture();
    if (image == null) return;

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/soko_output.png';
    final file = File(path);
    await file.writeAsBytes(image);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Зураг хадгалагдлаа: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Soko MGL Script')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedFont,
                items: ['MongolianScript', 'CmdAshitseden'].map((font) {
                  return DropdownMenuItem(
                    value: font,
                    child: Text(font),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedFont = value);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: pickImage,
              ),
              IconButton(
                icon: Icon(Icons.save),
                onPressed: saveImage,
              ),
            ],
          ),
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                decoration: backgroundImage != null
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(backgroundImage!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 3, // Vertical Mongolian
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: selectedFont,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => text = value),
              decoration: InputDecoration(labelText: 'Монгол бичгээр текст'),
            ),
          ),
        ],
      ),
    );
  }
}