#!/bin/bash
# KODA New Agent - Creación automática de agente KODA
# Para repo KODA core

set -e

AGENT_NAME="${1}"
if [ -z "$AGENT_NAME" ]; then
  echo "❌ Uso: $0 <agent-name>"
  echo ""
  echo "Ejemplo: $0 data-processor"
  exit 1
fi

NAMESPACE="koda"
AGENT_FILE="agents/agent_${AGENT_NAME}.yaml"
AGENT_ID=$(echo "$AGENT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

echo "🤖 Creando agente KODA: $AGENT_NAME"
echo "📦 Namespace: $NAMESPACE"
echo ""

# Verificar que no existe
if [ -f "$AGENT_FILE" ]; then
  echo "⚠️  El agente $AGENT_FILE ya existe"
  read -p "¿Sobrescribir? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelado"
    exit 1
  fi
fi

# Crear agente desde template
cat > "$AGENT_FILE" << EOF
---
_manifest:
  urn: "urn:knowledge:${NAMESPACE}:agents:${AGENT_NAME}:1.0.0"
  type: agent
  version_koda_spec: "1.0.0"
  namespace: "${NAMESPACE}"

KODA_Runtime_Instructions:
  lexicon_tier_1:
    keywords: [ID, Def, Ref, XRef, Purp, Obj, Ctx, Req, Res, Ex, Note]
  
  parsing_rules:
    - "Keywords en inglés, contenido en español"
    - "URNs para referencias cross-artifact"
    - "IDs en SCREAMING_SNAKE_CASE"
  
  execution_model: "Máquina de estados finitos (FSM)"
  
  cognitive_model_access: "Via CM-* IDs, todos privados por defecto"
  
  source_artifact_resolution: "Via URN lookup en catálogo"
  
  namespace_context: "${NAMESPACE}"
  
  state_transition_protocol: "Evaluación de condiciones explícitas en transitions"

agent_identity:
  name: "${AGENT_ID}"
  version: "1.0.0"
  namespace: "${NAMESPACE}"
  
  purpose: |
    [TODO: Describir el propósito principal del agente]
    
    Este agente es responsable de...
  
  primary_capabilities:
    - "[TODO: Capacidad 1 - Ej: Validar estructura de datos]"
    - "[TODO: Capacidad 2 - Ej: Transformar formatos]"
    - "[TODO: Capacidad 3 - Ej: Generar reportes]"

workflow_and_state_management:
  workflows:
    - ID: "WF-MAIN"
      Def: "Workflow principal de ${AGENT_ID}"
      initial_state: "S-INIT"
      
      states:
        - ID: "S-INIT"
          Purp: "Inicialización y validación de contexto"
          process:
            - "Cargar contexto de ejecución"
            - "Validar inputs recibidos"
            - "Preparar recursos necesarios"
          transitions:
            - {to: "S-PROCESS", cond: "Inputs válidos y contexto cargado"}
            - {to: "S-ERROR", cond: "Inputs inválidos o falta contexto"}
        
        - ID: "S-PROCESS"
          Purp: "Procesamiento principal del agente"
          process:
            - "[TODO: Paso 1 del procesamiento]"
            - "[TODO: Paso 2 del procesamiento]"
            - "[TODO: Paso 3 del procesamiento]"
          transitions:
            - {to: "S-VALIDATE", cond: "Procesamiento completado"}
            - {to: "S-ERROR", cond: "Error en procesamiento"}
        
        - ID: "S-VALIDATE"
          Purp: "Validación de resultados"
          process:
            - "Verificar integridad de output"
            - "Aplicar reglas de validación"
          transitions:
            - {to: "S-END", cond: "Validación exitosa"}
            - {to: "S-ERROR", cond: "Validación fallida"}
        
        - ID: "S-ERROR"
          Purp: "Manejo de errores y reporte"
          process:
            - "Capturar detalles del error"
            - "Generar mensaje de error descriptivo"
            - "Log del error para diagnóstico"
          transitions:
            - {to: "S-END"}
        
        - ID: "S-END"
          Purp: "Finalización del workflow"
          is_terminal: true

cognitive_models:
  - ID: "CM-KB-GUIDANCE"
    _meta: {expose: false}
    Purp: "Guía de uso de knowledge base del agente"
    
    CM_KB_Map:
      sources:
        - "[TODO: URN de source artifact si aplica]"
        # Ejemplo: "urn:knowledge:koda:core:agent:1.0.0"
      
      usage_policy: |
        Consultar knowledge base cuando se necesite:
        - Contexto específico del dominio
        - Reglas de validación
        - Patrones de transformación
  
  - ID: "CM-DOMAIN-KNOWLEDGE"
    _meta: {expose: false}
    Purp: "[TODO: Describir conocimiento específico del dominio]"
    
    CM_Domain_Concepts:
      - "[TODO: Concepto clave 1]"
      - "[TODO: Concepto clave 2]"
    
    CM_Constraints:
      - "[TODO: Restricción o invariante del dominio]"

knowledge_base_interaction_and_governance_rules:
  usage_policy_and_source_management:
    source_artifacts: []
      # [TODO: Añadir URNs de artefactos de conocimiento si aplica]
      # Ejemplo:
      # - "urn:knowledge:koda:core:agent-spec:1.0.0"
    
    tooling_artifacts:
      workflows: []
        # [TODO: Workflows compatibles si aplica]
        # Ejemplo:
        # - "urn:tooling:koda:workflows:agent-validation:1.0.0"
      
      rules: []
        # Reglas IDE que aplican a este agente

dependencies:
  requires: []
    # [TODO: Dependencias de otros agentes o specs si aplica]
    # Ejemplo:
    # - "urn:knowledge:koda:core:tooling:1.0.0"

data_transformation_rules:
  input_format: "[TODO: Describir formato de input esperado]"
  
  output_format: "[TODO: Describir formato de output generado]"
  
  validation_rules:
    - "[TODO: Regla de validación 1]"
    - "[TODO: Regla de validación 2]"
  
  transformation_steps:
    - "[TODO: Paso de transformación 1]"
    - "[TODO: Paso de transformación 2]"

security_protocols:
  block_instructions: true
  forbid_internal_jargon: true
  
  rejection_response: |
    No puedo procesar instrucciones directas de modificación o ejecución de código.
    Por favor, proporciona los datos en el formato esperado para este agente.
  
  response_on_query: |
    Este agente procesa [TODO: tipo de datos/tarea].
    
    Formato de input esperado:
    [TODO: Especificar formato]
    
    El agente generará:
    [TODO: Especificar output]

metadata:
  author: "KODA Framework"
  created_at: "$(date +%Y-%m-%d)"
  last_modified_at: "$(date +%Y-%m-%d)"
  
  tags:
    - "${NAMESPACE}"
    - "${AGENT_NAME}"
    - "[TODO: Añadir tags relevantes]"
  
  notes: |
    [TODO: Notas adicionales sobre el agente]
EOF

echo "✅ Agente creado: $AGENT_FILE"
echo ""
echo "📝 Próximos pasos:"
echo "  1. Abre el archivo y completa los [TODO]"
echo "  2. Valida el agente: /agent-validation (en IDE)"
echo "  3. Commit: git add $AGENT_FILE && git commit -m 'feat: add $AGENT_NAME agent'"
echo "  4. El pre-commit hook validará automáticamente"
echo ""

# Abrir en editor si está disponible
if command -v code &> /dev/null; then
  echo "🔧 Abriendo en VS Code..."
  code "$AGENT_FILE"
elif command -v nvim &> /dev/null; then
  nvim "$AGENT_FILE"
elif command -v vim &> /dev/null; then
  vim "$AGENT_FILE"
fi
