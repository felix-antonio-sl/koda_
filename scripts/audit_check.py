import yaml
import os
from pathlib import Path

def audit_koda(root_dir):
    catalog_path = os.path.join(root_dir, 'catalog', 'catalog_master_koda.yml')
    
    print(f"Auditing KODA at {root_dir}")
    print(f"Reading catalog: {catalog_path}")
    
    try:
        with open(catalog_path, 'r') as f:
            catalog = yaml.safe_load(f)
    except Exception as e:
        print(f"Error reading catalog: {e}")
        return

    files_in_catalog = set()
    missing_files = []
    
    # Sections to check for file paths
    sections = ['Core_Guides', 'Schemas', 'Agents', 'Skills', 'IDE_Tools', 'Gist']
    
    if 'Catalog' in catalog:
        for section in sections:
            if section in catalog['Catalog']:
                print(f"Checking section: {section}")
                for item in catalog['Catalog'][section]:
                    if 'file' in item:
                        file_path = os.path.join(root_dir, item['file'])
                        files_in_catalog.add(os.path.abspath(file_path))
                        
                        if not os.path.exists(file_path):
                            missing_files.append({
                                'section': section,
                                'urn': item.get('urn', 'unknown'),
                                'file': item['file']
                            })
    
    # Check for orphaned files
    orphaned_files = []
    
    # Directories to scan for orphans
    scan_dirs = ['knowledge', 'agents', 'schemas', 'skills']
    
    for scan_dir in scan_dirs:
        abs_scan_dir = os.path.join(root_dir, scan_dir)
        if not os.path.exists(abs_scan_dir):
            continue
            
        for root, dirs, files in os.walk(abs_scan_dir):
            for file in files:
                if file.endswith('.yml') or file.endswith('.yaml') or file.endswith('.json') or file.endswith('.md'):
                    # Skip hidden files
                    if file.startswith('.'):
                        continue
                        
                    abs_path = os.path.abspath(os.path.join(root, file))
                    
                    # Special cases to ignore
                    if 'node_modules' in abs_path: 
                        continue
                    if 'catalog_master' in file:
                        continue
                        
                    if abs_path not in files_in_catalog:
                        # Normalize path for reporting
                        rel_path = os.path.relpath(abs_path, root_dir)
                        orphaned_files.append(rel_path)

    # Report results
    print("\n--- AUDIT RESULTS ---")
    
    if missing_files:
        print(f"\n[MISSING FILES] ({len(missing_files)})")
        for missed in missing_files:
            print(f"  - [{missed['section']}] {missed['urn']}")
            print(f"    Path: {missed['file']}")
    else:
        print("\n[OK] No missing files referenced in catalog.")

    if orphaned_files:
        print(f"\n[ORPHANED FILES] ({len(orphaned_files)}) - Files on disk but not in catalog")
        for orphan in orphaned_files:
            print(f"  - {orphan}")
    else:
        print("\n[OK] No orphaned files found.")

if __name__ == "__main__":
    audit_koda('/Users/felixsanhueza/Developer/koda')
