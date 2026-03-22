import 'package:flutter_test/flutter_test.dart';
import 'package:vytal_app/utils/l10n.dart';

void main() {
  group('L10n Tests', () {
    test('L10n.t() should return the same key string when key does not exist', () {
      // Act
      final result = L10n.t('non_existent_key_12345');

      // Assert
      expect(result, 'non_existent_key_12345');
    });
  });
}
