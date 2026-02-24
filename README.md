# DetectPlants

A real-time, on-device plant identification app built with Flutter and TensorFlow Lite. Snap a photo or upload an image, and instantly identify the plant species using an EfficientNetB0 model running entirely on your device.

## Overview

DetectPlants runs a TensorFlow Lite inference pipeline locally on Android — no internet connection, no backend server, no data leaves the device. The app preprocesses captured images into Float32 tensors, runs them through a quantized EfficientNetB0 model on a background Dart Isolate, and displays the identified species with a confidence score.

### Key Features
- **On-Device AI** — Uses `tflite_flutter` with Dart `Isolate` for background inference. No network calls, fully offline.
- **Real-Time Capture** — Take a photo or pick from gallery via `image_picker`, get results in seconds.
- **47 Plant Species** — Identifies plants ranging from Monstera Deliciosa and Snake Plant to Orchids and Aloe Vera.
- **Plug-and-Play Models** — Dynamically reads model output shape at runtime, allowing easy swapping of `.tflite` models without code changes.
- **Material 3 UI** — Clean, modern interface with a minimalist two-screen flow.

---

## Supported Plants

The model can identify the following 47 species (alphabetical order):

> African Violet · Aloe Vera · Anthurium · Areca Palm · Asparagus Fern · Begonia · Bird of Paradise · Birds Nest Fern · Boston Fern · Calathea · Cast Iron Plant · Chinese Evergreen · Chinese Money Plant · Christmas Cactus · Chrysanthemum · Ctenanthe · Daffodils · Dracaena · Dumb Cane · Elephant Ear · English Ivy · Hyacinth · Iron Cross Begonia · Jade Plant · Kalanchoe · Lily of the Valley · Lilium · Money Tree · Monstera Deliciosa · Orchid · Parlor Palm · Peace Lily · Poinsettia · Polka Dot Plant · Ponytail Palm · Pothos · Prayer Plant · Rattlesnake Plant · Rubber Plant · Sago Palm · Schefflera · Snake Plant · Tradescantia · Tulip · Venus Flytrap · Yucca · ZZ Plant

---

## Technical Architecture

### Flutter Frontend
Two-screen Material 3 app with zero external state management:
- **`DashboardScreen`** — Landing page with camera and gallery buttons.
- **`ScanResultScreen`** — Displays the captured image, identified species, model class index, and confidence percentage.

### TFLite Inference Engine (`tflite_inference_service.dart`)
- **Model**: EfficientNetB0 (~4.5MB quantized `.tflite`)
- **Input**: `[1, 224, 224, 3]` Float32 tensor — raw RGB pixel values (0–255 scale, no normalization)
- **Preprocessing**: Image resizing and pixel extraction runs on a background `Isolate` as a flat `Float32List`, then reconstructed into 4D tensor on the main thread to avoid Isolate memory corruption.
- **Output**: Dynamically sized based on model output shape — supports any class count.

---

## Installation & Build

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.10.4)
- Android Studio with an emulator, or a physical Android device

### Setup
```bash
git clone https://github.com/AryanKo/DetectPlants.git
cd DetectPlants
flutter clean
flutter pub get
flutter run
```

### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

The release build uses R8/ProGuard shrinking (`isMinifyEnabled`, `isShrinkResources`) for a compact binary.

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, Material 3 theme
├── screens/
│   ├── dashboard_screen.dart          # Camera/gallery launcher
│   └── scan_result_screen.dart        # Results display
└── services/
    └── tflite_inference_service.dart   # TFLite model loading, preprocessing, inference
assets/
    └── new_model.tflite               # EfficientNetB0 quantized model
```
