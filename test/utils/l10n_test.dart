import 'package:flutter_test/flutter_test.dart';
import 'package:vytal_app/utils/l10n.dart';

void main() {
  setUp(() {
    // Reset to default before each test to ensure test isolation
    L10n.setLanguage('en');
  });

  group('L10n', () {
    test('default language should be english', () {
      expect(L10n.currentLanguage, 'en');
      expect(L10n.t('system_initializing'), 'VYTAL SYSTEM\nINITIALIZING...');
    });

    test('should change language to ru and return correct translation', () {
      L10n.setLanguage('ru');
      expect(L10n.currentLanguage, 'ru');
      expect(L10n.t('system_initializing'), 'СИСТЕМА VYTAL\nИНИЦИАЛИЗАЦИЯ...');
    });

    test('should return the key if translation is not found', () {
      const nonExistentKey = 'non_existent_key_123';
      expect(L10n.t(nonExistentKey), nonExistentKey);
    });

    test('should ignore unsupported language code', () {
      L10n.setLanguage('fr');
      expect(L10n.currentLanguage, 'en');
    });
  });
}
