import 'package:image/image.dart';

import '../defaults.dart';

/// Represents a single frame in an animation
class PepperAnimationFrame {
  /// Creates a new animation frame
  const PepperAnimationFrame({
    required this.offset,
    required this.size,
    required this.duration,
  });

  /// The offset (x, y) of this frame in the sprite sheet
  final (int, int) offset;

  /// The size (width, height) of this frame
  final (int, int) size;

  /// The duration of this frame in seconds
  final double duration;

  /// Creates a copy with optional overrides
  PepperAnimationFrame copyWith({
    (int, int)? offset,
    (int, int)? size,
    double? duration,
  }) {
    return PepperAnimationFrame(
      offset: offset ?? this.offset,
      size: size ?? this.size,
      duration: duration ?? this.duration,
    );
  }
}

/// Represents an animation composed of multiple frames
class PepperAnimation {
  /// Creates a new animation
  PepperAnimation({
    required this.frames,
    required this.tileSize,
    required this.name,
  });

  /// Creates an animation from JSON
  factory PepperAnimation.fromJson(Map<String, dynamic> json) {
    final framesJson = json['frames'] as List<dynamic>;
    final frames = framesJson.map((value) {
      final frameJson = value as Map<String, dynamic>;
      final offsetList = frameJson['offset'] as List<dynamic>;
      final sizeList = frameJson['size'] as List<dynamic>;
      return PepperAnimationFrame(
        offset: (offsetList[0] as int, offsetList[1] as int),
        size: (sizeList[0] as int, sizeList[1] as int),
        duration: (frameJson['duration'] as num).toDouble(),
      );
    }).toList();

    return PepperAnimation(
      frames: frames,
      tileSize: json['tileSize'] as int,
      name: json['name'] as String,
    );
  }

  /// The frames in this animation
  final List<PepperAnimationFrame> frames;

  /// The size of each tile in the animation
  final int tileSize;

  /// The name of this animation
  final String name;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tileSize': tileSize,
      'frames': frames
          .map(
            (frame) => {
              'offset': [frame.offset.$1, frame.offset.$2],
              'size': [frame.size.$1, frame.size.$2],
              'duration': frame.duration,
            },
          )
          .toList(),
    };
  }

  /// Creates a copy with optional overrides
  PepperAnimation copyWith({
    List<PepperAnimationFrame>? frames,
    int? tileSize,
    String? name,
  }) {
    return PepperAnimation(
      frames: frames ?? this.frames,
      tileSize: tileSize ?? this.tileSize,
      name: name ?? this.name,
    );
  }

  /// Creates a copy with an updated frame at the given index
  PepperAnimation copyWithUpdatedFrame(int index, PepperAnimationFrame frame) {
    final newFrames = List<PepperAnimationFrame>.from(frames);
    newFrames[index] = frame;
    return copyWith(frames: newFrames);
  }

  /// Creates a copy with a new frame added
  PepperAnimation copyWithAddedFrame(PepperAnimationFrame frame) {
    final newFrames = List<PepperAnimationFrame>.from(frames)..add(frame);
    return copyWith(frames: newFrames);
  }

  /// Creates a copy with a frame removed
  PepperAnimation copyWithRemovedFrame(PepperAnimationFrame frame) {
    final index = frames.indexOf(frame);
    final newFrames = List<PepperAnimationFrame>.from(frames)..removeAt(index);
    return copyWith(frames: newFrames);
  }
}

/// Represents a complete Pepper Sprite file
class PepperSpriteFile {
  /// Creates a new sprite file
  PepperSpriteFile({
    required this.id,
    required this.name,
    required this.userId,
    required this.colors,
    required this.layers,
    required this.tileSize,
    required this.editorGridSize,
    required this.editorGridColor,
    required this.editorBackgroundColor,
    this.animations = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Creates an empty sprite file with default values
  factory PepperSpriteFile.empty({
    required String id,
    required String name,
    required String userId,
    required int width,
    required int height,
    required int tileSize,
  }) {
    return PepperSpriteFile(
      id: id,
      name: name,
      userId: userId,
      colors: Defaults.palette,
      layers: [Image(width: width, height: height, numChannels: 4)],
      animations: [],
      tileSize: tileSize,
      editorGridSize: Defaults.defaultGridSize,
      editorBackgroundColor: Defaults.defaultFileBackgroundColor,
      editorGridColor: Defaults.defaultGridColor,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// The width of the sprite
  int get width => layers.isNotEmpty ? layers[0].width : 0;

  /// The height of the sprite
  int get height => layers.isNotEmpty ? layers[0].height : 0;

  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Owner user ID
  final String userId;

  /// Color palette
  final List<Color> colors;

  /// Image layers
  final List<Image> layers;

  /// Animations
  final List<PepperAnimation> animations;

  /// The size of each tile
  final int tileSize;

  /// Grid size for editor
  final int editorGridSize;

  /// Grid color for editor
  final Color editorGridColor;

  /// Background color for editor
  final Color editorBackgroundColor;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Creates a copy with optional overrides
  PepperSpriteFile copyWith({
    String? id,
    String? name,
    String? userId,
    List<Color>? colors,
    List<Image>? layers,
    List<PepperAnimation>? animations,
    int? tileSize,
    int? editorGridSize,
    Color? editorGridColor,
    Color? editorBackgroundColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PepperSpriteFile(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      colors: colors ?? this.colors,
      layers: layers ?? this.layers,
      animations: animations ?? this.animations,
      tileSize: tileSize ?? this.tileSize,
      editorGridSize: editorGridSize ?? this.editorGridSize,
      editorGridColor: editorGridColor ?? this.editorGridColor,
      editorBackgroundColor:
          editorBackgroundColor ?? this.editorBackgroundColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a copy with an updated animation
  PepperSpriteFile copyWithUpdatedAnimation(
    int index,
    PepperAnimation animation,
  ) {
    final newAnimations = List<PepperAnimation>.from(animations);
    newAnimations[index] = animation;
    return copyWith(animations: newAnimations);
  }

  /// Creates a copy with a new animation added
  PepperSpriteFile copyWithAddedAnimation(PepperAnimation animation) {
    final newAnimations = List<PepperAnimation>.from(animations)
      ..add(animation);
    return copyWith(animations: newAnimations);
  }

  /// Renders all layers into a single image
  Image renderImage() {
    if (layers.isEmpty) {
      return Image(width: 1, height: 1);
    }

    final width = layers.first.width;
    final height = layers.first.height;
    final result = Image(width: width, height: height, numChannels: 4);

    for (final layer in layers) {
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          if (x < layer.width && y < layer.height) {
            final pixel = layer.getPixel(x, y);
            if (pixel.a > 0) {
              result.setPixel(x, y, pixel);
            }
          }
        }
      }
    }

    return result;
  }
}
