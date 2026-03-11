import os

# ТЕПЕРЬ ищем Dart и настройки Flutter
EXTENSIONS = {'.dart', '.yaml', '.xml'}

# Игнорируем системные папки Flutter и сборки
IGNORE_DIRS = {
    '.git', '.idea', 'build', '.dart_tool', '.gradle',
    'android', 'ios', 'web', 'macos', 'linux', 'windows'
    # Я добавил папки платформ (android/ios) в игнор,
    # чтобы не тащить лишний нативный код.
    # Если тебе нужен именно нативный код, убери их из этого списка.
}

output_file = 'full_flutter_code.txt'
count = 0

print(f"--- ЗАПУСК ДЛЯ FLUTTER: {os.getcwd()} ---")

with open(output_file, 'w', encoding='utf-8') as outfile:
    for root, dirs, files in os.walk("."):
        # Фильтруем папки
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]

        for file in files:
            file_ext = os.path.splitext(file)[1].lower()

            # Ловим .dart и pubspec.yaml
            if file_ext in EXTENSIONS or file == 'pubspec.lock':
                file_path = os.path.join(root, file)

                # Исключаем сам скрипт и результат
                if 'merge_project.py' in file or file == output_file:
                    continue

                print(f"Вижу файл: {file_path}")
                count += 1

                outfile.write(f"\n\n{'='*50}\n")
                outfile.write(f"FILE: {file_path}\n")
                outfile.write(f"{'='*50}\n\n")

                try:
                    with open(file_path, 'r', encoding='utf-8') as infile:
                        outfile.write(infile.read())
                except Exception as e:
                    print(f"Ошибка чтения {file_path}: {e}")

print(f"--- ГОТОВО ---")
print(f"Найдено Dart-файлов: {count}")
print(f"Файл сохранен как: {output_file}")