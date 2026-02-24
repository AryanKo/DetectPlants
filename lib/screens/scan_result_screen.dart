import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_disease_app/services/tflite_inference_service.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;

  const ScanResultScreen({super.key, required this.imagePath});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isProcessing = true;
  InferenceResult? _resultInfo;
  final TFLiteInferenceService _inferenceService = TFLiteInferenceService();

  @override
  void initState() {
    super.initState();
    _initAndRun();
  }

  Future<void> _initAndRun() async {
    await _inferenceService.initModel();
    _runInference();
  }

  Future<void> _runInference() async {
    setState(() => _isProcessing = true);
    try {
      final info = await _inferenceService.runInference(widget.imagePath);

      if (!mounted) return;
      setState(() {
        _resultInfo = info;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inference failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Identifying plant...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else if (_resultInfo != null)
              _buildResultsDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Identification Results',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          'Plant Species',
          _resultInfo!.label,
          Icons.local_florist,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          'Model Class',
          'Class ${_resultInfo!.predictedIndex}',
          Icons.numbers,
          Colors.deepPurple,
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          'Match Confidence',
          '${(_resultInfo!.confidence * 100).toStringAsFixed(1)}%',
          Icons.verified,
          _resultInfo!.confidence > 0.5 ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildResultCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
