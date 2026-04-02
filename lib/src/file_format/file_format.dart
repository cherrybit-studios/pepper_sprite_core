import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart';

import '../defaults.dart';
import '../models/models.dart';

/// Handles serialization and deserialization of PSP files
class PspFileFormat {
  /// Private constructor
  PspFileFormat._();

  /// Serializes a PepperSpriteFile to bytes
  static Uint8List serialize(PepperSpriteFile file) {
    final animationsJson =
        file.animations.map((animation) => animation.toJson()).toList();

    final imageBytes = file.layers.map((layer) => layer.getBytes()).toList();

    final metadata = {
      'width': file.width,
      'height': file.height,
      'tileSize': file.tileSize,
      'animations': animationsJson,
      'colors': file.colors.map((c) => [c.a, c.r, c.g, c.b]).toList(),
      'images': imageBytes.map((b) => b.length).toList(),
      'editorGridSize': file.editorGridSize,
      'editorGridColor': [
        file.editorGridColor.a,
        file.editorGridColor.r,
        file.editorGridColor.g,
        file.editorGridColor.b,
      ],
      'editorBackgroundColor': [
        file.editorBackgroundColor.a,
        file.editorBackgroundColor.r,
        file.editorBackgroundColor.g,
        file.editorBackgroundColor.b,
      ],
    };

    final metadataBytes = jsonEncode(metadata).codeUnits;
    const separatorByte = 0x00;

    final bytes = BytesBuilder()
      ..add(metadataBytes)
      ..addByte(separatorByte);

    imageBytes.forEach(bytes.add);

    return bytes.toBytes();
  }

  /// Deserializes bytes to a PepperSpriteFile
  static PepperSpriteFile deserialize(
    String fileId,
    Map<String, dynamic> metadata,
    Uint8List bytes,
  ) {
    final buffer = <int>[];
    final byteList = bytes.toList();
    Map<String, dynamic>? fileData;
    final layers = <Image>[];

    while (fileData == null) {
      final current = byteList.removeAt(0);

      if (current == 0x00) {
        final metadataString = utf8.decode(buffer);
        fileData = jsonDecode(metadataString) as Map<String, dynamic>;
        buffer.clear();
      } else {
        buffer.add(current);
      }
    }

    final animationsJson = fileData['animations'] as List<dynamic>;
    final animations = animationsJson
        .map((json) => PepperAnimation.fromJson(json as Map<String, dynamic>))
        .toList();

    final colors = (fileData['colors'] as List<dynamic>).map((colorList) {
      final colorValues = colorList as List<dynamic>;
      return ColorInt16.rgba(
        colorValues[1] as int,
        colorValues[2] as int,
        colorValues[3] as int,
        colorValues[0] as int,
      );
    }).toList();

    final layerLengths = (fileData['images'] as List<dynamic>)
        .map((length) => length as int)
        .toList();

    for (final length in layerLengths) {
      final layerBytes = byteList.sublist(0, length);
      byteList.removeRange(0, length);
      layers.add(
        Image.fromBytes(
          width: fileData['width'] as int,
          height: fileData['height'] as int,
          bytes: Uint8List.fromList(layerBytes).buffer,
          numChannels: 4,
        ),
      );
    }

    return PepperSpriteFile(
      id: fileId,
      name: metadata['name'] as String,
      userId: metadata['userId'] as String,
      animations: animations,
      layers: layers,
      colors: colors,
      tileSize:
          (fileData['tileSize'] as int?) ?? Defaults.defaultGridSize,
      editorGridSize:
          (fileData['editorGridSize'] as int?) ?? Defaults.defaultGridSize,
      editorGridColor: () {
        final colorValues = fileData?['editorGridColor'] as List<dynamic>?;

        if (colorValues == null) {
          return Defaults.defaultGridColor;
        }
        return ColorInt16.rgba(
          colorValues[1] as int,
          colorValues[2] as int,
          colorValues[3] as int,
          colorValues[0] as int,
        );
      }(),
      editorBackgroundColor: () {
        final colorValues =
            fileData?['editorBackgroundColor'] as List<dynamic>?;

        if (colorValues == null) {
          return Defaults.defaultFileBackgroundColor;
        }
        return ColorInt16.rgba(
          colorValues[1] as int,
          colorValues[2] as int,
          colorValues[3] as int,
          colorValues[0] as int,
        );
      }(),
      createdAt: metadata['createdAt'] != null
          ? DateTime.tryParse(metadata['createdAt']! as String)
          : null,
      updatedAt: metadata['updatedAt'] != null
          ? DateTime.tryParse(metadata['updatedAt']! as String)
          : null,
    );
  }
}
