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
  static const String modelPath = 'assets/new_model.tflite';
  Interpreter? _interpreter;
  bool _isInit = false;

  Future<void> initModel() async {
    if (_isInit) return;
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _interpreter!.allocateTensors();
      _isInit = true;
    } catch (e) {
      debugPrint("Failed to load model: $e");
    }
  }

Future<InferenceResult> runInference(String imagePath) async {
    if (!_isInit) await initModel();
    if (_interpreter == null) throw Exception("Interpreter not initialized");

    final flatInput = await Isolate.run(() => _preprocessImage(imagePath));
    // 2. Reconstruct the 4D tensor safely on the main UI thread
    final inputTensor = List.generate(1, (i) => 
      List.generate(224, (y) => 
        List.generate(224, (x) {
          final base = (y * 224 + x) * 3;
          return [
            flatInput[base],
            flatInput[base + 1],
            flatInput[base + 2],
          ];
        })
      )
    );

    final outputShape = _interpreter!.getOutputTensors().first.shape;
    final numClasses = outputShape.last;

    var outputTensor = List.generate(1, (i) => List.filled(numClasses, 0.0));
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

    final String label = _getDeterministicLabel(maxIndex, numClasses);

    return InferenceResult(
      predictedIndex: maxIndex,
      confidence: maxProb,
      rawOutput: outputList,
      label: label,
    );
  }

  static Float32List _preprocessImage(String imagePath) {
    final imageFile = File(imagePath);
    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes);

    if (image == null) throw Exception("Failed to decode image");

    final resizedImage = img.copyResize(
      image, 
      width: 224, 
      height: 224, 
      interpolation: img.Interpolation.linear
    );
    
    final float32List = Float32List(224 * 224 * 3);
    int index = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixelSafe(x, y);
        float32List[index++] = pixel.r.toDouble();
        float32List[index++] = pixel.g.toDouble();
        float32List[index++] = pixel.b.toDouble();
      }
    }

    return float32List;
  }

  /// Maps model output index to plant species name (alphabetically sorted by dataset folder)
  String _getDeterministicLabel(int index, int numClasses) {
      final labels = [
        "African Violet",          // 0
        "Aloe Vera",               // 1
        "Anthurium",               // 2
        "Areca Palm",              // 3
        "Asparagus Fern",          // 4
        "Begonia",                 // 5
        "Bird of Paradise",        // 6
        "Birds Nest Fern",         // 7
        "Boston Fern",             // 8
        "Calathea",                // 9
        "Cast Iron Plant",         // 10
        "Chinese Evergreen",       // 11
        "Chinese Money Plant",     // 12
        "Christmas Cactus",        // 13
        "Chrysanthemum",           // 14
        "Ctenanthe",               // 15
        "Daffodils",               // 16
        "Dracaena",                // 17
        "Dumb Cane",               // 18
        "Elephant Ear",            // 19
        "English Ivy",             // 20
        "Hyacinth",                // 21
        "Iron Cross Begonia",      // 22
        "Jade Plant",              // 23
        "Kalanchoe",               // 24
        "Lily of the Valley",      // 25
        "Lilium",                  // 26
        "Money Tree",              // 27
        "Monstera Deliciosa",      // 28
        "Orchid",                  // 29
        "Parlor Palm",             // 30
        "Peace Lily",              // 31
        "Poinsettia",              // 32
        "Polka Dot Plant",         // 33
        "Ponytail Palm",           // 34
        "Pothos",                  // 35
        "Prayer Plant",            // 36
        "Rattlesnake Plant",       // 37
        "Rubber Plant",            // 38
        "Sago Palm",               // 39
        "Schefflera",              // 40
        "Snake Plant",             // 41
        "Tradescantia",            // 42
        "Tulip",                   // 43
        "Venus Flytrap",           // 44
        "Yucca",                   // 45
        "ZZ Plant",                // 46
      ];
      
      if (index >= 0 && index < labels.length) return labels[index];
      return "Unknown Class [$index]";
  }
}