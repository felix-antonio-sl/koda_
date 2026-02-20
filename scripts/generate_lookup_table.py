#!/usr/bin/env python3
"""
koda-migrator: Fase 0 — Generación de Lookup Table
Extrae todas las URNs de los catalog_master_*.yml y genera
la tabla de migración hacia Single Namespace KODA.

Uso: python3 scripts/generate_lookup_table.py
"""

from pathlib import Path
import yaml
import csv
import sys
import json

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

# === Reglas de mapeo de dominios ===
# Formato: (namespace_legacy, domain_legacy) -> new_domain
DOMAIN_MAP = {
    # koda — ya son koda:*, sin cambio de dominio
    ("koda", "core"): "core",
    ("koda", "agents"): "agents",
    ("koda", "skills"): "skills",
    ("koda", "antigravity"): "tools",
    ("koda", "codex"): "tools",
    ("koda", "claude"): "tools",
    ("koda", "registry"): "core",
    ("koda", "tooling"): "tools",
    ("koda", "catalog"): "catalog",
    # fxsl
    ("fxsl", "agents"): "agents",
    ("fxsl", "med"): "legal",  # fxsl:med:legislacion:* -> legal
    ("fxsl", "cat"): "cat",
    ("fxsl", "mbt"): "core",  # MBT es metodología core
    ("fxsl", "gist"): "core",  # Gist upper ontology -> core
    ("fxsl", "catalog"): "catalog",
    # gorenuble
    ("gorenuble", "agents"): "agents",
    ("gorenuble", "gn"): "gn",
    ("gorenuble", "core"): "mgmt",  # gorenuble:core:gestion:* -> mgmt
    ("gorenuble", "ipr"): "mgmt",  # IPR -> mgmt
    ("gorenuble", "schemas"): "core",
    ("gorenuble", "catalog"): "catalog",
    ("gorenuble", "presupuesto"): "gn",  # presupuesto GORE -> gn
    ("gorenuble", "ontology"): "core",  # ontología institucional
    # tde
    ("tde", "agents"): "agents",
    ("tde", "core"): "gov",  # tde:core -> gov (principios TDE)
    ("tde", "ontology"): "gov",  # ontología TDE -> gov
    ("tde", "estrategias"): "gov",
    ("tde", "leyes"): "legal",
    ("tde", "normas"): "legal",
    ("tde", "plataformas"): "gov",
    ("tde", "guias"): "gov",
    ("tde", "arquitectura"): "sys",
    ("tde", "catalog"): "catalog",
    # orko
    ("orko", "core"): "core",
    ("orko", "metodologia"): "core",
    ("orko", "implementacion"): "core",
    ("orko", "agents"): "agents",
    ("orko", "catalog"): "catalog",
    # korvo
    ("korvo", "agents"): "agents",
    ("korvo", "catalog"): "catalog",
    # moltbot (namespace externo hospedado en fxsl)
    ("moltbot", "concepts"): "tools",
    ("moltbot", "cli"): "tools",
    ("moltbot", "gateway"): "tools",
    ("moltbot", "channels"): "tools",
    ("moltbot", "tools"): "tools",
    ("moltbot", "platforms"): "tools",
    ("moltbot", "operations"): "tools",
    # Namespaces referenciados en koda registry (no procesados directamente)
    ("sanixai", "catalog"): "catalog",
    ("goreos", "catalog"): "catalog",
}


def parse_urn(urn_str: str) -> dict:
    """Parsea urn:knowledge:{ns}:{domain}:{artifact}:{version}
    Maneja URNs con subdominios como fxsl:med:legislacion:artifact:version
    """
    parts = urn_str.replace("urn:knowledge:", "").split(":")
    if len(parts) < 3:
        return None

    namespace = parts[0]
    version = parts[-1]

    # Detectar si hay subdominios (ej: med:legislacion:artifact -> domain=med, artifact=legislacion:artifact)
    # La convención KODA es ns:domain:artifact:version (4 partes)
    # Pero fxsl:med:legislacion:index:1.0.0 tiene 5 partes
    if len(parts) == 4:
        domain = parts[1]
        artifact = parts[2]
    elif len(parts) == 5:
        domain = parts[1]
        # El "subdominio" se incorpora al nombre del artefacto si no es redundante
        sub = parts[2]
        artifact = parts[3]
        # Para med:legislacion:ley_15076 -> artifact queda como está
        # El contexto disciplinar (legislacion) ya está capturado en domain mapping
    elif len(parts) >= 6:
        domain = parts[1]
        artifact = ":".join(parts[2:-1])
    else:
        return None

    return {
        "namespace": namespace,
        "domain": domain,
        "artifact": artifact,
        "version": version,
        "original_urn": urn_str,  # Preservar URN original completa
    }


def map_urn(parsed: dict, workspace: str) -> dict:
    """Genera la nueva URN bajo el namespace koda."""
    ns = parsed["namespace"]
    dom = parsed["domain"]
    artifact = parsed["artifact"]
    version = parsed["version"]

    # Buscar mapeo de dominio
    new_domain = DOMAIN_MAP.get((ns, dom))
    if new_domain is None:
        new_domain = dom  # Mantener sin cambio si no hay regla
        print(
            f"  ⚠️  Sin regla para ({ns}, {dom}), manteniendo dominio '{dom}'",
            file=sys.stderr,
        )

    # Generar contexto para metadata del catálogo
    if ns == "koda":
        context = "koda"
    elif ns == "moltbot":
        context = "moltbot"
    else:
        context = {
            "fxsl": "fx",
            "gorenuble": "gn",
            "tde": "tde",
            "orko": "orko",
            "korvo": "kv",
        }.get(ns, ns)

    # Prefijo para evitar colisiones en core (orko:core vs koda:core vs tde:core)
    needs_prefix = new_domain == "core" and ns not in ("koda",)
    if needs_prefix:
        prefix = context
        if not artifact.startswith(f"{prefix}-") and not artifact.startswith(f"{ns}-"):
            artifact = f"{prefix}-{artifact}"

    # Prefijo especial para implementacion vs core en orko (toolkit colisión)
    if ns == "orko" and dom == "implementacion":
        if not artifact.startswith("impl-"):
            artifact = f"impl-{artifact}"

    # Los catálogos mantienen su workspace como diferenciador
    if new_domain == "catalog":
        ws_suffix = ns if ns != "koda" else "koda"
        artifact = f"master-{ws_suffix}"

    new_urn = f"urn:knowledge:koda:{new_domain}:{artifact}:{version}"

    return {
        "urn_legacy": parsed["original_urn"],
        "urn_new": new_urn,
        "domain_new": new_domain,
        "context": context,
        "origin_workspace": workspace,
    }


def extract_urns_from_catalog(catalog_path: Path, workspace: str) -> list:
    """Extrae todas las URNs de un catalog_master_*.yml"""
    results = []
    try:
        with open(catalog_path, "r") as f:
            data = yaml.safe_load(f)
    except Exception as e:
        print(f"Error leyendo {catalog_path}: {e}", file=sys.stderr)
        return results

    if not data:
        return results

    # Recorrer recursivamente buscando claves 'urn'
    def walk(obj):
        if isinstance(obj, dict):
            if "urn" in obj:
                urn_val = str(obj["urn"])
                if urn_val.startswith("urn:knowledge:"):
                    parsed = parse_urn(urn_val)
                    if parsed:
                        mapped = map_urn(parsed, workspace)
                        mapped["title"] = obj.get("title", "")
                        mapped["file"] = obj.get("file", "")
                        results.append(mapped)
            for v in obj.values():
                walk(v)
        elif isinstance(obj, list):
            for item in obj:
                walk(item)

    walk(data)
    return results


def validate_collisions(all_entries: list) -> list:
    """Detecta colisiones: URNs nuevas duplicadas."""
    seen = {}
    collisions = []
    for entry in all_entries:
        key = entry["urn_new"]
        if key in seen:
            collisions.append((entry, seen[key]))
        else:
            seen[key] = entry
    return collisions


def main():
    all_entries = []

    print("=" * 60)
    print("KODA Migrator — Fase 0: Generación de Lookup Table")
    print("=" * 60)

    for ws_name, ws_path in WORKSPACES.items():
        catalog_path = ws_path / "catalog" / f"catalog_master_{ws_name}.yml"
        if not catalog_path.exists():
            print(f"\n⚠️  No se encontró catálogo: {catalog_path}")
            continue

        print(f"\n📦 Procesando: {ws_name} ({catalog_path.name})")
        entries = extract_urns_from_catalog(catalog_path, ws_name)
        print(f"   → {len(entries)} URNs extraídas")
        all_entries.extend(entries)

    # Validar colisiones
    print(f"\n{'=' * 60}")
    print(f"📊 Total URNs: {len(all_entries)}")
    collisions = validate_collisions(all_entries)
    if collisions:
        print(f"❌ COLISIONES DETECTADAS: {len(collisions)}")
        for c1, c2 in collisions:
            print(f"   {c1['urn_new']}")
            print(f"     ← {c1['urn_legacy']} ({c1['origin_workspace']})")
            print(f"     ← {c2['urn_legacy']} ({c2['origin_workspace']})")
    else:
        print("✅ CERO COLISIONES — migración segura")

    # Generar YAML de lookup table
    output_path = Path("/tmp/koda_lookup_table.yml")
    output_path.parent.mkdir(parents=True, exist_ok=True)

    lookup_data = {
        "_meta": {
            "description": "Lookup Table de migración KODA Single Namespace",
            "generated_at": "2026-02-20",
            "total_entries": len(all_entries),
            "collisions": len(collisions),
        },
        "entries": [],
    }

    for entry in sorted(all_entries, key=lambda x: x["urn_new"]):
        lookup_data["entries"].append(
            {
                "urn_legacy": entry["urn_legacy"],
                "urn_new": entry["urn_new"],
                "domain": entry["domain_new"],
                "context": entry["context"],
                "origin_workspace": entry["origin_workspace"],
            }
        )

    with open(output_path, "w") as f:
        yaml.dump(
            lookup_data,
            f,
            default_flow_style=False,
            allow_unicode=True,
            sort_keys=False,
        )
    print(f"\n💾 Lookup Table generada: {output_path}")

    # Generar CSV también
    csv_path = output_path.with_suffix(".csv")
    with open(csv_path, "w", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "urn_legacy",
                "urn_new",
                "domain",
                "context",
                "origin_workspace",
            ],
        )
        writer.writeheader()
        for entry in sorted(all_entries, key=lambda x: x["urn_new"]):
            writer.writerow(
                {
                    "urn_legacy": entry["urn_legacy"],
                    "urn_new": entry["urn_new"],
                    "domain": entry["domain_new"],
                    "context": entry["context"],
                    "origin_workspace": entry["origin_workspace"],
                }
            )
    print(f"💾 CSV generado: {csv_path}")


if __name__ == "__main__":
    main()
