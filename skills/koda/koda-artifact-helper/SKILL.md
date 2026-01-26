---
name: koda-artifact-helper
description: Ayuda a crear y validar artefactos KODA-compliant
version: 1.0.0
author: KODA Framework
tags: [koda, artifact, yaml, validation]
---

# KODA Artifact Helper

## Propósito

Esta skill asiste en la creación de artefactos YAML que cumplen con el estándar KODA/Spec. Garantiza que cada artefacto tenga la estructura correcta, el `_manifest` apropiado, y las `LLM_Parsing_Instructions` estándar.

## Cuándo Activar

Activa esta skill cuando el usuario:
- Solicite crear un nuevo artefacto de conocimiento
- Quiera transformar un documento a formato KODA
- Necesite validar la estructura de un artefacto existente
- Pregunte sobre el formato correcto de artefactos KODA

## Estructura Requerida de Artefactos KODA

Todo artefacto KODA debe seguir esta estructura:

```yaml
# Comentario de encabezado con título y versión
_manifest:
  urn: "urn:knowledge:{namespace}:{domain}:{artifact-id}:{version}"
  federation:
    visibility: public|internal|private
    license: "CC-BY-4.0"
  compatibility:
    min_consumer_version: "1.0.0"
  resolution:
    canonical_url: "file://{path}"
  dependencies:
    requires: []
  provenance:
    created_by: "{autor}"
    created_at: "{YYYY-MM-DD}"
    last_modified_at: "{YYYY-MM-DD}"

ID: ARTIFACT-ID-01
Version: 1.0.0
Status: Draft|Published|Deprecated
Classification: guide|kb|agent|schema
Domain: core|{custom-domain}
Title: "Título del Artefacto"
Summary: "Resumen breve"

LLM_Parsing_Instructions:
  ID: KODA-LLM-PARSER-01
  Req: Mandatory block following Metadata.
  Prohib: Using for artifact creation or translation.
  Content: |
    BEGIN_LLM_INSTRUCTIONS
    You are an AI agent consuming a KODA artifact. Parse with absolute fidelity.
    FIDELITY: Preserve meat (essential information) and skeleton (structure) with zero loss.
    LEXICON: Act->Action, Cond->Condition, Ctx->Context, Ctx_Required->Required External Reference, Ctx_Optional->Optional External Reference, Def->Definition, Ex->Example, Mssn->Mission, Obj->Objective, Proc->Process, Purp->Purpose, Ref->Reference, Req->Requirement, Res->Result, Src->Source, Prohib->Prohibition, Warn->Warning, Just->Justification, Rec->Recommendation
    REFERENCE POLICY: Ref: is internal only. External documents use Ctx:, Ctx_Required:, or Ctx_Optional:.
    LANGUAGE POLICY: Keywords in English, content in original language.
    END_LLM_INSTRUCTIONS

# Contenido del artefacto...
```

## Convención de Nombres

```
{tipo}_{dominio}_{número}_{nombre}_{namespace}.yml

Ejemplos:
- guide_core_001_koda-spec_koda.yml
- kb_legal_010_contratos-laborales_sanixai.yml
- agent_support_001_customer-service_acme.yml
```

## Validación

Antes de finalizar un artefacto, verificar:

1. **YAML válido**: Sintaxis YAML 1.2 correcta
2. **URN único**: Formato `urn:knowledge:{ns}:{domain}:{id}:{version}`
3. **_manifest completo**: Todos los campos requeridos presentes
4. **LLM_Parsing_Instructions**: Bloque estándar incluido
5. **Referencias internas**: Usar `Ref:` solo para referencias internas
6. **Referencias externas**: Usar `Ctx:`, `Ctx_Required:`, o `Ctx_Optional:`

## Lexicon KODA (Tier-1 Keywords)

| Keyword | Expansión | Uso |
|---------|-----------|-----|
| Act | Action | Acción a ejecutar |
| Cond | Condition | Condición lógica |
| Ctx | Context | Contexto externo opcional |
| Ctx_Required | Required External Reference | Dependencia externa requerida |
| Ctx_Optional | Optional External Reference | Dependencia externa opcional |
| Def | Definition | Definición de término |
| Ex | Example | Ejemplo ilustrativo |
| Mssn | Mission | Misión del artefacto |
| Obj | Objective | Objetivo específico |
| Proc | Process | Proceso o procedimiento |
| Purp | Purpose | Propósito |
| Ref | Reference | Referencia interna (solo interna) |
| Req | Requirement | Requisito |
| Res | Result | Resultado esperado |
| Src | Source | Fuente de información |
| Prohib | Prohibition | Prohibición explícita |
| Warn | Warning | Advertencia |
| Just | Justification | Justificación |
| Rec | Recommendation | Recomendación |

## Ejemplo de Uso

**Usuario**: "Crea un artefacto de conocimiento sobre políticas de seguridad"

**Acción**: Generar estructura KODA-compliant con:
- URN apropiado
- _manifest con provenance
- LLM_Parsing_Instructions estándar
- Contenido usando keywords del lexicon
