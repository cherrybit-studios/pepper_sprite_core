import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

import '../models/models.dart';

/// Exception thrown when export fails
class ExportException implements Exception {
  /// Creates an export exception
  ExportException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => message;
}

/// Exports Pepper Sprite files to various image formats
class ImageExporter {
  /// Private constructor
  ImageExporter._();

  /// Exports a sprite file to PNG
  static Uint8List exportToPng(PepperSpriteFile file) {
    final rendered = file.renderImage();
    final png = encodePng(rendered);
    return Uint8List.fromList(png);
  }

  /// Exports a sprite file to a file on disk
  static void exportToPngFile(PepperSpriteFile file, String outputPath) {
    final pngBytes = exportToPng(file);
    File(outputPath).writeAsBytesSync(pngBytes);
  }

  /// Exports a specific animation frame to PNG
  static Uint8List exportAnimationFrameToPng(
    PepperSpriteFile file,
    String animationName,
    int frameIndex,
  ) {
    final animation = file.animations.firstWhere(
      (a) => a.name == animationName,
      orElse: () => throw ExportException(
        'Animation "$animationName" not found',
      ),
    );

    if (frameIndex < 0 || frameIndex >= animation.frames.length) {
      throw ExportException(
        'Frame index $frameIndex out of range '
        '(animation has ${animation.frames.length} frames)',
      );
    }

    final frame = animation.frames[frameIndex];
    final rendered = file.renderImage();

    // Extract the frame from the sprite sheet
    final frameImage = copyCrop(
      rendered,
      x: frame.offset.$1,
      y: frame.offset.$2,
      width: frame.size.$1,
      height: frame.size.$2,
    );

    final png = encodePng(frameImage);
    return Uint8List.fromList(png);
  }

  /// Exports all frames of an animation to separate PNG files
  static void exportAnimationToPngFiles(
    PepperSpriteFile file,
    String animationName,
    String outputDirectory,
  ) {
    final animation = file.animations.firstWhere(
      (a) => a.name == animationName,
      orElse: () => throw ExportException(
        'Animation "$animationName" not found',
      ),
    );

    final dir = Directory(outputDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    for (var i = 0; i < animation.frames.length; i++) {
      final pngBytes = exportAnimationFrameToPng(file, animationName, i);
      final fileName = '${animationName}_frame_$i.png';
      File('${dir.path}/$fileName').writeAsBytesSync(pngBytes);
    }
  }
}
