#!/usr/bin/env python3
import json
import os

translation_dir = 'assets/translations'
languages = {}

# Load all translation files
for file in os.listdir(translation_dir):
    if file.endswith('.json'):
        with open(os.path.join(translation_dir, file), 'r', encoding='utf-8') as f:
            try:
                languages[file] = json.load(f)
            except json.JSONDecodeError as e:
                print(f'JSON Error in {file}: {e}')

print('=== TRANSLATION FILE CONSISTENCY ===')
if 'en-US.json' in languages:
    primary_keys = set(languages['en-US.json'].keys())
    print(f'Primary language (en-US): {len(primary_keys)} keys')
    
    for lang_file, translations in languages.items():
        if lang_file != 'en-US.json':
            lang_keys = set(translations.keys())
            missing = primary_keys - lang_keys
            extra = lang_keys - primary_keys
            
            print(f'{lang_file}: {len(lang_keys)} keys')
            if missing:
                print(f'  Missing: {len(missing)} keys')
            if extra:
                print(f'  Extra: {len(extra)} keys')
else:
    print('Primary language file (en-US.json) not found!')