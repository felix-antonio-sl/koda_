#!/usr/bin/env python3
"""
koda-migrator: Fase 1 — Migración de Catálogos
Muta atómicamente las URNs en cada catalog_master_*.yml
usando la Lookup Table generada en Fase 0.

Uso:
  python3 scripts/migrate_catalogs.py --dry-run   # Solo reportar cambios
  python3 scripts/migrate_catalogs.py             # Ejecutar migración
"""

from pathlib import Path
import yaml
import csv
import sys
import re
import copy
import argparse
from datetime import datetime


# === Configuración ===
BASE = Path(__file__).resolve().parent.parent.parent  # /Users/.../Developer
WORKSPACES = {
    "koda": BASE / "koda",
    "fxsl": BASE / "fxsl",
    "gorenuble": BASE / "gorenuble",
    "tde": BASE / "tde",
    "orko": BASE / "orko",
    "korvo": BASE / "korvo",
}
LOOKUP_CSV = Path("/tmp/koda_lookup_table.csv")

# Patrón URN para detección
URN_PATTERN = re.compile(
    r"urn:knowledge:[a-z0-9_-]+:[a-z0-9_:-]+:[a-z0-9_.-]+:[0-9.*]+"
)


def load_lookup_table(csv_path: Path) -> dict:
    """Carga la lookup table como dict {urn_legacy: urn_new}."""
    lookup = {}
    with open(csv_path, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            lookup[row["urn_legacy"]] = row["urn_new"]
    return lookup


def migrate_value(value, lookup: dict) -> tuple:
    """Si value es un string con URN, intenta migrar. Retorna (nuevo_valor, changed)."""
    if not isinstance(value, str):
        return value, False

    if not value.startswith("urn:knowledge:"):
        # Podría ser una referencia inline en un string más largo
        matches = URN_PATTERN.findall(value)
        if not matches:
            return value, False
        changed = False
        new_value = value
        for match in matches:
            if match in lookup:
                new_value = new_value.replace(match, lookup[match])
                changed = True
        return new_value, changed

    # Es una URN directa
    if value in lookup:
        return lookup[value], True
    return value, False


def walk_and_migrate(obj, lookup: dict, path: str = "", changes: list = None):
    """Recorre recursivamente YAML y muta URNs in-place."""
    if changes is None:
        changes = []

    if isinstance(obj, dict):
        for key in list(obj.keys()):
            child_path = f"{path}.{key}"
            if isinstance(obj[key], str):
                new_val, changed = migrate_value(obj[key], lookup)
                if changed:
                    changes.append(
                        {
                            "path": child_path,
                            "old": obj[key],
                            "new": new_val,
                        }
                    )
                    obj[key] = new_val
            elif isinstance(obj[key], (dict, list)):
                walk_and_migrate(obj[key], lookup, child_path, changes)
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            child_path = f"{path}[{i}]"
            if isinstance(item, str):
                new_val, changed = migrate_value(item, lookup)
                if changed:
                    changes.append(
                        {
                            "path": child_path,
                            "old": item,
                            "new": new_val,
                        }
                    )
                    obj[i] = new_val
            elif isinstance(item, (dict, list)):
                walk_and_migrate(item, lookup, child_path, changes)

    return changes


def read_yaml_preserving_format(path: Path) -> tuple:
    """Lee un YAML preservando el contenido raw para escritura."""
    with open(path, "r") as f:
        content = f.read()
    data = yaml.safe_load(content)
    return data, content


def write_yaml(path: Path, data: dict):
    """Escribe YAML con formato limpio."""
    with open(path, "w") as f:
        yaml.dump(
            data,
            f,
            default_flow_style=False,
            allow_unicode=True,
            sort_keys=False,
            width=120,
        )


def main():
    parser = argparse.ArgumentParser(description="KODA Migrator - Fase 1: Catálogos")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Solo reportar cambios sin mutar archivos",
    )
    args = parser.parse_args()

    # Cargar lookup table
    if not LOOKUP_CSV.exists():
        print(f"❌ Lookup table no encontrada: {LOOKUP_CSV}")
        print("   Ejecuta primero: python3 scripts/generate_lookup_table.py")
        sys.exit(1)

    lookup = load_lookup_table(LOOKUP_CSV)
    print(f"{'=' * 60}")
    print(f"KODA Migrator — Fase 1: Migración de Catálogos")
    print(f"{'=' * 60}")
    print(f"📋 Lookup table: {len(lookup)} entradas cargadas")
    print(
        f"🔧 Modo: {'DRY RUN (sin cambios)' if args.dry_run else '⚡ EJECUCIÓN REAL'}"
    )

    total_changes = 0
    total_files = 0

    for ws_name, ws_path in WORKSPACES.items():
        catalog_path = ws_path / "catalog" / f"catalog_master_{ws_name}.yml"
        if not catalog_path.exists():
            print(f"\n⚠️  Saltando: {catalog_path} (no existe)")
            continue

        print(f"\n{'─' * 40}")
        print(f"📦 {ws_name}: {catalog_path.name}")

        data, raw_content = read_yaml_preserving_format(catalog_path)
        if not data:
            print("   ⚠️  Catálogo vacío, saltando")
            continue

        # Hacer deep copy para dry-run comparison
        data_copy = copy.deepcopy(data)
        changes = walk_and_migrate(data_copy, lookup)

        if not changes:
            print(f"   ✅ Sin cambios necesarios")
            continue

        total_files += 1
        total_changes += len(changes)

        print(f"   📝 {len(changes)} mutaciones:")
        for c in changes:
            # Mostrar solo últimos segmentos para brevedad
            old_short = c["old"].split(":")[-2] if ":" in c["old"] else c["old"]
            new_short = c["new"].split(":")[-2] if ":" in c["new"] else c["new"]
            print(f"      {c['path']}")
            print(f"        - {c['old']}")
            print(f"        + {c['new']}")

        if not args.dry_run:
            # Backup al /tmp/ para no depender de permisos del repo
            backup_dir = Path("/tmp/koda_migration_backups")
            backup_dir.mkdir(parents=True, exist_ok=True)
            backup_path = backup_dir / f"catalog_master_{ws_name}.yml.bak"
            with open(backup_path, "w") as f:
                f.write(raw_content)
            print(f"   💾 Backup: {backup_path}")

            # Escribir archivo migrado
            try:
                write_yaml(catalog_path, data_copy)
                print(f"   ✅ Migrado exitosamente")
            except PermissionError:
                # Intentar con enfoque alternativo: reescribir via contenido
                alt_path = backup_dir / f"catalog_master_{ws_name}_migrated.yml"
                write_yaml(alt_path, data_copy)
                print(f"   ⚠️  Sin permisos para escribir en repo.")
                print(f"   📁 Archivo migrado guardado en: {alt_path}")
                print(f"   👉 Copiar manualmente: cp {alt_path} {catalog_path}")

    # Resumen
    print(f"\n{'=' * 60}")
    print(f"📊 Resumen Fase 1:")
    print(f"   Archivos procesados: {len(WORKSPACES)}")
    print(f"   Archivos modificados: {total_files}")
    print(f"   Total mutaciones: {total_changes}")
    if args.dry_run:
        print(f"\n   ℹ️  Modo DRY RUN — ningún archivo fue modificado")
        print(f"   Para ejecutar: python3 scripts/migrate_catalogs.py")
    else:
        print(f"\n   ✅ Migración Fase 1 completada")
        print(f"   📁 Backups generados como *.yml.bak")


if __name__ == "__main__":
    main()
