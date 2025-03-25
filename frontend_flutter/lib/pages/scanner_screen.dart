import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Interpreter _interpreter;
  late ImageProcessor _imageProcessor;
  late List<String> _labels;
  String _prediction = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
    _labels = await FileUtil.loadLabels('assets/labels.txt');

    int inputSize = _interpreter.getInputTensor(0).shape[1];
    _imageProcessor =
        ImageProcessorBuilder()
            .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
            .add(NormalizeOp(0, 255))
            .build();
  }

  Future<void> _predict(CameraImage cameraImage) async {
    if (_isProcessing) return;
    _isProcessing = true;

    Uint8List bytes = convertCameraImageToUint8List(cameraImage);
    if (bytes.isEmpty) {
      _isProcessing = false;
      return;
    }

    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      _isProcessing = false;
      return;
    }

    int inputSize = _interpreter.getInputTensor(0).shape[1];
    img.Image resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    TensorImage inputImage = TensorImage.fromImage(resizedImage);
    inputImage = _imageProcessor.process(inputImage);

    TensorBuffer outputBuffer = TensorBuffer.createFixedSize(
      _interpreter.getOutputTensor(0).shape,
      _interpreter.getOutputTensor(0).type,
    );

    _interpreter.run(inputImage.buffer, outputBuffer.buffer);

    List<double> output = outputBuffer.getDoubleList();
    if (output.isNotEmpty) {
      int maxIndex = output.indexOf(
        output.reduce((curr, next) => curr > next ? curr : next),
      );
      setState(() {
        _prediction = _labels[maxIndex];
      });
    }

    _isProcessing = false;
  }

  Uint8List convertCameraImageToUint8List(CameraImage cameraImage) {
    img.Image? image;
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      image = convertYUV420(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      image = convertBGRA8888(cameraImage);
    }
    return image != null
        ? Uint8List.fromList(img.encodeJpg(image))
        : Uint8List(0);
  }

  img.Image convertYUV420(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    img.Image image = img.Image(width, height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int Y = yBuffer[yIndex];
        final int U = uBuffer[uvIndex];
        final int V = vBuffer[uvIndex];

        image.setPixel(x, y, yuv2rgb(Y, U, V));
      }
    }
    return image;
  }

  img.Image convertBGRA8888(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final Uint8List bgraBytes = cameraImage.planes[0].bytes;

    // Create an empty image with the correct dimensions
    img.Image image = img.Image(width, height);

    int index = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int blue = bgraBytes[index]; // B
        int green = bgraBytes[index + 1]; // G
        int red = bgraBytes[index + 2]; // R
        int alpha = bgraBytes[index + 3]; // A

        // Convert to RGBA format
        image.setPixelRgba(x, y, red, green, blue, alpha);
        index += 4;
      }
    }

    return image;
  }

  int yuv2rgb(int y, int u, int v) {
    int r = (y + 1.13983 * (v - 128)).round().clamp(0, 255);
    int g = (y - 0.39465 * (u - 128) - 0.58060 * (v - 128)).round().clamp(
      0,
      255,
    );
    int b = (y + 2.03211 * (u - 128)).round().clamp(0, 255);
    return (255 << 24) | (b << 16) | (g << 8) | r;
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(child: CameraPreview(_controller)),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _controller.startImageStream((
                        CameraImage image,
                      ) async {
                        await _predict(image);
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text('Capture Image'),
                ),
                Text('Prediction: $_prediction'),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
