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

  static Image _applyScale(Image image, int? scaleWidth, int? scaleHeight) {
    if (scaleWidth == null && scaleHeight == null) {
      return image;
    }
    if (scaleWidth == null || scaleHeight == null) {
      throw ExportException(
        'Both scaleWidth and scaleHeight must be provided together',
      );
    }
    return copyResize(image, width: scaleWidth, height: scaleHeight);
  }

  /// Exports a sprite file to PNG.
  ///
  /// Optionally provide [scaleWidth] and [scaleHeight] to scale the exported
  /// image. Both must be provided together; passing only one throws an
  /// [ExportException].
  static Uint8List exportToPng(
    PepperSpriteFile file, {
    int? scaleWidth,
    int? scaleHeight,
  }) {
    final rendered = _applyScale(file.renderImage(), scaleWidth, scaleHeight);
    final png = encodePng(rendered);
    return Uint8List.fromList(png);
  }

  /// Exports a sprite file to a file on disk.
  ///
  /// Optionally provide [scaleWidth] and [scaleHeight] to scale the exported
  /// image. Both must be provided together; passing only one throws an
  /// [ExportException].
  static void exportToPngFile(
    PepperSpriteFile file,
    String outputPath, {
    int? scaleWidth,
    int? scaleHeight,
  }) {
    final pngBytes =
        exportToPng(file, scaleWidth: scaleWidth, scaleHeight: scaleHeight);
    File(outputPath).writeAsBytesSync(pngBytes);
  }

  /// Exports a specific animation frame to PNG.
  ///
  /// Optionally provide [scaleWidth] and [scaleHeight] to scale the exported
  /// frame. Both must be provided together; passing only one throws an
  /// [ExportException].
  static Uint8List exportAnimationFrameToPng(
    PepperSpriteFile file,
    String animationName,
    int frameIndex, {
    int? scaleWidth,
    int? scaleHeight,
  }) {
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
    var frameImage = copyCrop(
      rendered,
      x: frame.offset.$1,
      y: frame.offset.$2,
      width: frame.size.$1,
      height: frame.size.$2,
    );

    frameImage = _applyScale(frameImage, scaleWidth, scaleHeight);

    final png = encodePng(frameImage);
    return Uint8List.fromList(png);
  }

  /// Exports all frames of an animation to separate PNG files.
  ///
  /// Optionally provide [scaleWidth] and [scaleHeight] to scale each exported
  /// frame. Both must be provided together; passing only one throws an
  /// [ExportException].
  static void exportAnimationToPngFiles(
    PepperSpriteFile file,
    String animationName,
    String outputDirectory, {
    int? scaleWidth,
    int? scaleHeight,
  }) {
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
      final pngBytes = exportAnimationFrameToPng(
        file,
        animationName,
        i,
        scaleWidth: scaleWidth,
        scaleHeight: scaleHeight,
      );
      final fileName = '${animationName}_frame_$i.png';
      File('${dir.path}/$fileName').writeAsBytesSync(pngBytes);
    }
  }
}
