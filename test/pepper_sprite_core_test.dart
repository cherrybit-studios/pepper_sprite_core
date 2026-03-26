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
      );

      expect(file.id, equals('test-id'));
      expect(file.name, equals('Test'));
      expect(file.userId, equals('user-123'));
      expect(file.width, equals(32));
      expect(file.height, equals(32));
      expect(file.layers, hasLength(1));
    });

    test('renderImage returns merged layers', () {
      final file = PepperSpriteFile.empty(
        id: 'test',
        name: 'Test',
        userId: 'user',
        width: 10,
        height: 10,
      );

      final rendered = file.renderImage();
      expect(rendered.width, equals(10));
      expect(rendered.height, equals(10));
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
}
