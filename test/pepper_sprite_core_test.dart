import 'package:pepper_sprite_core/pepper_sprite_core.dart';
import 'package:test/test.dart';

void main() {
  group('PepperSpriteFile', () {
    test('can create empty file', () {
      final file = PepperSpriteFile.empty(
        id: 'test-id',
        name: 'Test',
        userId: 'user-123',
        width: 32,
        height: 32,
        tileSize: 16,
      );

      expect(file.id, equals('test-id'));
      expect(file.name, equals('Test'));
      expect(file.userId, equals('user-123'));
      expect(file.width, equals(32));
      expect(file.height, equals(32));
      expect(file.tileSize, equals(16));
      expect(file.layers, hasLength(1));
    });

    test('renderImage returns merged layers', () {
      final file = PepperSpriteFile.empty(
        id: 'test',
        name: 'Test',
        userId: 'user',
        width: 10,
        height: 10,
        tileSize: 16,
      );

      final rendered = file.renderImage();
      expect(rendered.width, equals(10));
      expect(rendered.height, equals(10));
    });

    test('copyWith updates tileSize', () {
      final file = PepperSpriteFile.empty(
        id: 'test',
        name: 'Test',
        userId: 'user',
        width: 16,
        height: 16,
        tileSize: 16,
      );

      final updated = file.copyWith(tileSize: 32);
      expect(updated.tileSize, equals(32));
      expect(file.tileSize, equals(16));
    });
  });

  group('PepperAnimation', () {
    test('can convert to and from JSON', () {
      final animation = PepperAnimation(
        name: 'walk',
        tileSize: 16,
        frames: [
          PepperAnimationFrame(
            offset: (0, 0),
            size: (16, 16),
            duration: 0.1,
          ),
        ],
      );

      final json = animation.toJson();
      final restored = PepperAnimation.fromJson(json);

      expect(restored.name, equals('walk'));
      expect(restored.tileSize, equals(16));
      expect(restored.frames, hasLength(1));
    });
  });

  group('Defaults', () {
    test('has default palette', () {
      expect(Defaults.palette, isNotEmpty);
    });

    test('has default grid size', () {
      expect(Defaults.defaultGridSize, equals(16));
    });
  });

  group('ImageExporter', () {
    PepperSpriteFile makeFile({int width = 16, int height = 16}) =>
        PepperSpriteFile.empty(
          id: 'test',
          name: 'Test',
          userId: 'user',
          width: width,
          height: height,
          tileSize: 16,
        );

    group('exportToPng', () {
      test('returns PNG bytes without scaling', () {
        final file = makeFile();
        final bytes = ImageExporter.exportToPng(file);
        expect(bytes, isNotEmpty);
      });

      test('scales image when both scaleWidth and scaleHeight are provided',
          () {
        final file = makeFile(width: 16, height: 16);
        final scaledBytes = ImageExporter.exportToPng(
          file,
          scaleWidth: 32,
          scaleHeight: 32,
        );
        expect(scaledBytes, isNotEmpty);
        // Scaled PNG should differ from un-scaled (larger image)
        final unscaledBytes = ImageExporter.exportToPng(file);
        expect(scaledBytes.length, greaterThan(unscaledBytes.length));
      });

      test('throws ExportException when only scaleWidth is provided', () {
        final file = makeFile();
        expect(
          () => ImageExporter.exportToPng(file, scaleWidth: 32),
          throwsA(isA<ExportException>()),
        );
      });

      test('throws ExportException when only scaleHeight is provided', () {
        final file = makeFile();
        expect(
          () => ImageExporter.exportToPng(file, scaleHeight: 32),
          throwsA(isA<ExportException>()),
        );
      });
    });

    group('exportAnimationFrameToPng', () {
      PepperSpriteFile makeFileWithAnimation() {
        final file = makeFile(width: 32, height: 16);
        return file.copyWithAddedAnimation(
          PepperAnimation(
            name: 'run',
            tileSize: 16,
            frames: [
              PepperAnimationFrame(
                offset: (0, 0),
                size: (16, 16),
                duration: 0.1,
              ),
              PepperAnimationFrame(
                offset: (16, 0),
                size: (16, 16),
                duration: 0.1,
              ),
            ],
          ),
        );
      }

      test('scales frame when both scaleWidth and scaleHeight are provided',
          () {
        final file = makeFileWithAnimation();
        final scaledBytes = ImageExporter.exportAnimationFrameToPng(
          file,
          'run',
          0,
          scaleWidth: 32,
          scaleHeight: 32,
        );
        expect(scaledBytes, isNotEmpty);
        final unscaledBytes =
            ImageExporter.exportAnimationFrameToPng(file, 'run', 0);
        expect(scaledBytes.length, greaterThan(unscaledBytes.length));
      });

      test('throws ExportException when only scaleWidth is provided', () {
        final file = makeFileWithAnimation();
        expect(
          () => ImageExporter.exportAnimationFrameToPng(
            file,
            'run',
            0,
            scaleWidth: 32,
          ),
          throwsA(isA<ExportException>()),
        );
      });

      test('throws ExportException when only scaleHeight is provided', () {
        final file = makeFileWithAnimation();
        expect(
          () => ImageExporter.exportAnimationFrameToPng(
            file,
            'run',
            0,
            scaleHeight: 32,
          ),
          throwsA(isA<ExportException>()),
        );
      });
    });
  });
}
