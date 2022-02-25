import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = true;
  File? image;
  List? outputs;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) => setState(() {}));
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      outputs = output;
      loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;
    setState(() {
      image = File(pickedFile.path);
      loading = true;
    });
    detectImage(File(pickedFile.path));
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50.0),
            const Text(
              'Sabik Rahat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.0,
              ),
            ),
            const SizedBox(height: 5.0),
            const Text(
              'Cat & Dog Detector App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
            const Spacer(),
            Center(
              child: loading
                  ? Image.asset(
                      'assets/cat_dog_icon.png',
                      height: size.height * 0.5,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.file(
                          File(image!.path),
                          height: size.height * 0.5,
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          outputs != null
                              ? 'This is probably a ${outputs![0]["label"]}'
                              : "Sorry, can't detect.",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickImage(ImageSource.camera),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                    ),
                    child: const Text(
                      'Capture a Photo',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickImage(ImageSource.gallery),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                    ),
                    child: const Text(
                      'Select a Photo',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }
}
