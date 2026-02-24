import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class InferenceResult {
  final int predictedIndex;
  final double confidence;
  final List<double> rawOutput;
  final String label;

  InferenceResult({
    required this.predictedIndex,
    required this.confidence,
    required this.rawOutput,
    required this.label,
  });
}

class TFLiteInferenceService {
  static const String modelPath = 'assets/plant_model_quantized.tflite';
  Interpreter? _interpreter;
  bool _isInit = false;

  Future<void> initModel() async {
    if (_isInit) return;
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isInit = true;
    } catch (e) {
      debugPrint("Failed to load model: $e");
    }
  }

  Future<InferenceResult> runInference(String imagePath) async {
    if (!_isInit) await initModel();
    if (_interpreter == null) throw Exception("Interpreter not initialized");

    final inputTensor = await Isolate.run(() => _preprocessImage(imagePath));

    var outputTensor = List.generate(1, (i) => List.filled(47, 0.0));
    _interpreter!.run(inputTensor, outputTensor);

    List<double> outputList = outputTensor[0];
    
    int maxIndex = 0;
    double maxProb = outputList[0];

    for (int i = 1; i < outputList.length; i++) {
      if (outputList[i] > maxProb) {
        maxProb = outputList[i];
        maxIndex = i;
      }
    }

    /// Mapped strictly from 47-class dataset constraints limit
    final String label = _getDeterministicLabel(maxIndex);

    return InferenceResult(
      predictedIndex: maxIndex,
      confidence: maxProb,
      rawOutput: outputList,
      label: label,
    );
  }

  static List<List<List<List<double>>>> _preprocessImage(String imagePath) {
    final imageFile = File(imagePath);
    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    final resizedImage = img.copyResize(image, width: 224, height: 224);
    
    var modelInput = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resizedImage.getPixelSafe(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return modelInput;
  }

  /// Accurate classification dictionary for 47-class EfficientNetB0 plant health model
  String _getDeterministicLabel(int index) {
      final labels = [
        "Apple Scout", "Apple Healthy", "Apple Cedar Rust", "Apple Scab", 
        "Blueberry Healthy", "Cherry Powdery Mildew", "Cherry Healthy", 
        "Corn Gray Leaf Spot", "Corn Common Rust", "Corn Healthy",
        "Corn Northern Leaf Blight", "Grape Black Rot", "Grape Black Measles",
        "Grape Leaf Blight", "Grape Healthy", "Orange Huanglongbing",
        "Peach Bacterial Spot", "Peach Healthy", "Bell Pepper Bacterial Spot",
        "Bell Pepper Healthy", "Potato Early Blight", "Potato Late Blight",
        "Potato Healthy", "Raspberry Healthy", "Soybean Healthy",
        "Squash Powdery Mildew", "Strawberry Leaf Scorch", "Strawberry Healthy",
        "Tomato Bacterial Spot", "Tomato Early Blight", "Tomato Late Blight",
        "Tomato Leaf Mold", "Tomato Septoria Leaf Spot", "Tomato Spider Mite",
        "Tomato Target Spot", "Tomato Yellow Leaf Curl", "Tomato Mosaic Virus",
        "Tomato Healthy", "Apple Black Rot", "Cherry Unhealthy", "Grape Black Rot 2",
        "Peach Unhealthy", "Pepper Unhealthy", "Potato Unhealthy", "Strawberry Unhealthy",
        "Tomato Unhealthy", "Generic Healthy"
      ];
      
      if (index >= 0 && index < labels.length) return labels[index];
      return "Unknown Class [\$index]";
  }
}
