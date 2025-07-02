#!/usr/bin/env python3
import json
import re
import os

def extract_simple_tr_calls(file_path):
    """Extract simple .tr() calls (like Text('string').tr()) from a Dart file"""
    tr_calls = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Look for simpler patterns - just string literals followed by .tr()
        # This will catch: "string".tr() and 'string'.tr()
        patterns = [
            r"['\"]([^'\"]+)['\"]\.tr\(\)",
            r"Text\s*\(\s*['\"]([^'\"]+)['\"].*?\)\.tr\(\)"
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content, re.DOTALL)
            for match in matches:
                clean_match = match.strip()
                # Skip dynamic strings (those with ${} interpolation)
                if not ('${' in clean_match or clean_match.startswith('$')):
                    tr_calls.append(clean_match)
                
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    
    return tr_calls

def main():
    # Load primary translation file
    with open('assets/translations/en-US.json', 'r', encoding='utf-8') as f:
        translations = json.load(f)
    
    translation_keys = set(translations.keys())
    
    # Find all Dart files
    dart_files = []
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    # Extract all tr() calls
    all_tr_calls = set()
    file_tr_mapping = {}
    
    for dart_file in dart_files:
        tr_calls = extract_simple_tr_calls(dart_file)
        if tr_calls:
            file_tr_mapping[dart_file] = tr_calls
            all_tr_calls.update(tr_calls)
    
    # Check for missing keys
    missing_keys = all_tr_calls - translation_keys
    
    print(f"=== CRITICAL LOCALIZATION ERRORS ===")
    print(f"Total simple localization keys found: {len(all_tr_calls)}")
    print(f"Missing from translations: {len(missing_keys)}")
    
    if missing_keys:
        print(f"\n❌ MISSING TRANSLATION KEYS:")
        for key in sorted(missing_keys):
            print(f"  • \"{key}\"")
            
            # Find which files use this key
            files_using_key = []
            for file_path, keys in file_tr_mapping.items():
                if key in keys:
                    rel_path = os.path.relpath(file_path)
                    files_using_key.append(rel_path)
            
            if files_using_key:
                print(f"    Used in: {', '.join(files_using_key[:3])}")
                if len(files_using_key) > 3:
                    print(f"    ... and {len(files_using_key) - 3} more files")
            print()
    
    # Look for potential mismatches
    print(f"\n=== POTENTIAL MISMATCHES ===")
    for key in sorted(missing_keys):
        # Check if similar key exists
        for trans_key in translation_keys:
            if key.lower() in trans_key.lower() or trans_key.lower() in key.lower():
                if abs(len(key) - len(trans_key)) <= 5:  # Similar length
                    print(f"  • Missing: \"{key}\"")
                    print(f"    Similar: \"{trans_key}\" -> \"{translations[trans_key]}\"")
                    print()
                    break

if __name__ == "__main__":
    main()