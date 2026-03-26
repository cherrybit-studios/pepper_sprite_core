import 'package:image/image.dart';

/// Default values for Pepper Sprite files
abstract class Defaults {
  /// Default color palette
  static final palette = [
    // Black
    ColorInt16.rgba(0, 0, 0, 255),
    // White
    ColorInt16.rgba(255, 255, 255, 255),
    // Red
    ColorInt16.rgba(255, 0, 0, 255),
    // Cyan
    ColorInt16.rgba(0, 255, 255, 255),
    // Purple
    ColorInt16.rgba(128, 0, 128, 255),
    // Green
    ColorInt16.rgba(0, 255, 0, 255),
    // Blue
    ColorInt16.rgba(0, 0, 255, 255),
    // Yellow
    ColorInt16.rgba(255, 255, 0, 255),
    // Orange
    ColorInt16.rgba(255, 165, 0, 255),
    // Brown
    ColorInt16.rgba(165, 42, 42, 255),
  ];

  /// Black color
  static final blackColor = ColorInt16.rgba(
    0,
    0,
    0,
    255,
  );

  /// Default background color
  static final defaultFileBackgroundColor = ColorInt16.rgba(
    220,
    220,
    220,
    255,
  );

  /// Default grid color
  static final defaultGridColor = ColorInt16.rgba(
    150,
    150,
    150,
    255,
  );

  /// Default grid size
  static const defaultGridSize = 16;
}
