import shutil
import os

# Что заменяем
old_prefix = "advancedEBF"

# Новые варианты префикса
new_prefixes = [
    "largeFluidExtractor"
]

# Файлы, в которых меняем префикс
file_templates = [
    "advancedEBFActive.png",
    "advancedEBF.png",
    "advancedEBFActive.png.mcmeta",
    "advancedEBF.png.mcmeta",
    "advancedEBFActiveGlow.png",
    "advancedEBFGlow.png",
    "advancedEBFActiveGlow.png.mcmeta",
    "advancedEBFGlow.png.mcmeta"
]

# Папка, где лежит скрипт и файлы
current_dir = os.path.dirname(os.path.abspath(__file__))

for template in file_templates:
    src_path = os.path.join(current_dir, template)
    if not os.path.exists(src_path):
        print(f"Файл не найден: {template}")
        continue

    for prefix in new_prefixes:
        new_name = template.replace(old_prefix, prefix, 1)  # только первое вхождение
        dest_path = os.path.join(current_dir, new_name)
        shutil.copy2(src_path, dest_path)
        print(f"Создан файл: {new_name}")

print("Готово!")
