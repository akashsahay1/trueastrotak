#!/usr/bin/env python3
import json
import re
import os
import subprocess

def extract_tr_calls_from_file(file_path):
    """Extract all .tr() calls from a Dart file"""
    tr_calls = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Pattern to match Text('string').tr() or Text("string").tr()
        patterns = [
            r"Text\s*\(\s*['\"]([^'\"]+)['\"].*?\)\.tr\(\)",
            r"['\"]([^'\"]+)['\"].*?\.tr\(\)",
            r"tr\s*\(\s*['\"]([^'\"]+)['\"]\s*\)"
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content, re.DOTALL)
            for match in matches:
                tr_calls.append(match.strip())
                
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    
    return tr_calls

def find_dart_files(directory):
    """Find all Dart files in directory"""
    dart_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def main():
    # Load translation files
    translations = {}
    translation_dir = 'assets/translations'
    
    if os.path.exists(translation_dir):
        for file in os.listdir(translation_dir):
            if file.endswith('.json'):
                with open(os.path.join(translation_dir, file), 'r', encoding='utf-8') as f:
                    translations[file] = json.load(f)
    
    # Get primary translation keys (en-US.json)
    primary_keys = set()
    if 'en-US.json' in translations:
        primary_keys = set(translations['en-US.json'].keys())
    
    print(f"Found {len(primary_keys)} keys in primary translation file (en-US.json)")
    
    # Find all Dart files
    dart_files = find_dart_files('lib')
    print(f"Scanning {len(dart_files)} Dart files...")
    
    # Extract all tr() calls
    all_tr_calls = set()
    file_tr_mapping = {}
    
    for dart_file in dart_files:
        tr_calls = extract_tr_calls_from_file(dart_file)
        if tr_calls:
            file_tr_mapping[dart_file] = tr_calls
            all_tr_calls.update(tr_calls)
    
    print(f"Found {len(all_tr_calls)} unique localization keys used in code")
    
    # Check for missing keys
    missing_keys = all_tr_calls - primary_keys
    unused_keys = primary_keys - all_tr_calls
    
    print(f"\n=== LOCALIZATION ANALYSIS ===")
    print(f"Keys in code: {len(all_tr_calls)}")
    print(f"Keys in translations: {len(primary_keys)}")
    print(f"Missing from translations: {len(missing_keys)}")
    print(f"Unused in code: {len(unused_keys)}")
    
    if missing_keys:
        print(f"\n❌ MISSING KEYS ({len(missing_keys)}):")
        for key in sorted(missing_keys):
            print(f"  - \"{key}\"")
            # Find which files use this key
            for file_path, keys in file_tr_mapping.items():
                if key in keys:
                    rel_path = os.path.relpath(file_path)
                    print(f"    Used in: {rel_path}")
            print()
    
    if unused_keys:
        print(f"\n⚠️  UNUSED KEYS ({len(unused_keys)}):")
        for key in sorted(list(unused_keys)[:10]):  # Show first 10
            print(f"  - \"{key}\"")
        if len(unused_keys) > 10:
            print(f"  ... and {len(unused_keys) - 10} more")
    
    print(f"\n✅ VALID KEYS: {len(all_tr_calls & primary_keys)}")

if __name__ == "__main__":
    main()