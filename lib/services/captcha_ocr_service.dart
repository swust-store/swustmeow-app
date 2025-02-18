import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class CaptchaOCRService {
  late Interpreter _interpreter;
  static const String _charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  Future<void> initialize() async {
    try {
      // 加载模型
      _interpreter = await Interpreter.fromAsset('assets/ocr.tflite');
      _interpreter.allocateTensors();
      debugPrint('OCR 模型加载成功');
      var inputTensors = _interpreter.getInputTensors();
      debugPrint('输入 Tensors: $inputTensors');
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
      debugPrint('OCR 模型加载成功：$e');
    }
  }

  Future<String> recognize(Uint8List imageBytes) async {
    final input = await _preprocessImage(imageBytes);
    final input4D = input.reshape([1, 200, 50, 1]);
    final outputShape = _interpreter.getOutputTensor(0).shape;
    final output = List.filled(
      outputShape.reduce((a, b) => a * b),
      0.0,
    ).reshape(outputShape);
    _interpreter.run(input4D, output);
    return _decodeOutput(output);
  }

  Future<Float32List> _preprocessImage(Uint8List imageBytes) async {
    img.Image image = img.decodeImage(imageBytes)!;
    image = img.grayscale(image);

    // 调整尺寸逻辑
    const targetModelWidth = 50;
    const targetModelHeight = 200;
    final resizedImage = img.copyResize(
      image,
      width: targetModelWidth,
      height: (image.height * targetModelWidth / image.width).round(),
    );

    // 填充到模型输入尺寸
    final paddedImage = _padToModelInput(
      resizedImage,
      targetModelWidth,
      targetModelHeight,
    );

    // 转换为模型需要的Float32格式（假设归一化到[-1,1]）
    final inputBuffer = Float32List(1 * 200 * 50 * 1);
    int index = 0;
    // 注意遍历顺序：先高度（y）后宽度（x）
    for (int y = 0; y < 200; y++) {    // 对应模型输入高度200
      for (int x = 0; x < 50; x++) {   // 对应模型输入宽度50
        final pixel = paddedImage.getPixel(x, y).luminance;
        inputBuffer[index++] = (pixel / 127.5) - 1.0;
      }
    }
    return inputBuffer;
  }

  img.Image _padToModelInput(
      img.Image image, int targetWidth, int targetHeight) {
    final canvas = img.Image(width: targetWidth, height: targetHeight);

    // 旧方法（不可用）: canvas.fill(color: ...)
    // 新方法: 逐像素填充背景色
    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        canvas.setPixel(x, y, img.ColorRgb8(0, 0, 0)); // 设置黑色背景
      }
    }

    // 计算居中坐标
    final offsetX = (targetWidth - image.width) ~/ 2;
    final offsetY = (targetHeight - image.height) ~/ 2;

    img.compositeImage(
      canvas,
      image,
      dstX: offsetX,
      dstY: offsetY,
    );
    return canvas;
  }

  String _decodeOutput(List<dynamic> output) {
    final predictions = output[0] as List<List<double>>;
    return predictions.map((charProbs) => _charset[_argMax(charProbs)]).join();
  }

  int _argMax(List<double> probs) {
    int maxIndex = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[maxIndex]) maxIndex = i;
    }
    return maxIndex;
  }

  void dispose() => _interpreter.close();
}
