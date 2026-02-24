---
_manifest:
  urn: "urn:knowledge:koda:core:stack-agentes:1.0.0"
---

# Spec: Stack de Desarrollo para Agentes LLM

> **SSOT:** Documento prescriptivo para la arquitectura base y stack tecnológico en el desarrollo de agentes basados en LLM dentro del ecosistema KODA.
> **Fecha de Actualización:** 2026-02-24

Este documento establece un stack de desarrollo estructurado y unificado, sintetizando las mejores prácticas comprobadas para maximizar la eficacia, predictibilidad y eficiencia de modelos de frontera (LLMs) como Claude, Gemini y la serie de OpenAI.

---

## 🏗️ Principios Generales del Stack Nativo de IA

1. **Minimización de Ambigüedad:** Los LLMs rinden exponencialmente mejor cuando operan sobre lenguajes fuertemente tipados y contratos estructurales (JSON Schema, OpenAPI).
2. **Preferencia Categórica por el Ecosistema Dominante:** Se privilegian tecnologías con sobre-representación masiva en los datos de entrenamiento de los modelos fundacionales (como Python y TypeScript) frente a lenguajes esotéricos.
3. **Enfoque Declarativo:** La lógica paso a paso se cambia por descripciones de estado final deseado (React, Tailwind, Terraform, SQL) siempre que sea posible.
4. **Validación Temprana:** Se delega la prevención de alucinaciones sintácticas a los compiladores de tipos (TypeScript/Pydantic) antes que a complejas validaciones en caliente en tiempo de ejecución.

---

## 🖥️ 1. Frontend y Experiencia de Usuario (UX)

- **Lenguaje Base:** TypeScript. Las fallas de la IA al generar UI son predominantemente problemas de tipos u omisiones de propiedades; TypeScript opera como el guardrail nativo.
- **Framework Core:** React + Next.js (App Router). El estándar omnipresente para la creación de interfaces. Los LLMs "respiran" patrones de React, posibilitando la pre-generación de componentes robustos y coherentes a escala.
- **Estilos y Componentes:** Tailwind CSS acoplado a bibliotecas como Shadcn UI. Tailwind convierte atributos espaciales en tokens de texto exactos que el LLM puede emparejar a su lógica sin necesidad de inferir hojas de estilos complejas y cruzadas.
- **Validación Compartida:** Zod para empaquetado y validación de esquemas (JSON Schema validation) compartido vía Server Actions / BFF (Backend For Frontend).

---

## 🧠 2. Backend y Capa Cognitiva (APIs y Tooling)

- **Lenguaje Base:** Python (procesamiento algorítmico e integración ML) con `typing` estructurado, o TypeScript para entornos Node.
- **Diseño de APIs para Agentes (Tooling):** El flujo de comunicación debe orientarse a RESTful APIs estandarizadas utilizando contratos OpenAPI o gRPC para requerimientos de muy baja latencia. FastAPI (Python) es la opción preferente por su integración nativa de Pydantic y tipado automático de JSON Schema, crítico para que el *Tool Calling* no colapse los parsers del LLM.
- **Contratos y Validación (Core del Agente):** Todo intercambio, invocación o ejecución de acción debe validarse mediante una especificación rigurosa de JSON Schema. Modelos como Claude exigen validación mediante formato de uso de herramientas estricto (*strict tool use*).
- **Streaming de Respuestas:** El diseño de la API debe contemplar Server-Sent Events (SSE) u opciones de streaming para el retorno progresivo de tokens e información de estado directamente.
- **Entorno de Desarrollo Asistido (CLIs):** El ciclo de codificación e iteración local se potencia de manera orquestada usando asistentes de línea de comandos de última generación:
  - **Claude Code CLI:** Para refactorizaciones complejas de contexto amplio y agentic coding de alta precisión.
  - **Gemini CLI (Antigravity):** Para interacciones analíticas multicapa integradas nativamente en flujos definidos por la terminal (como en KODA).
  - **Codex CLI:** Para iteración rápida y autocompletado en flujos de bash directos u operativas rápidas de OS.

---

## 🗄️ 3. Capa de Datos, Vectorización y Memoria

- **Base de Datos Principal:** PostgreSQL. La versatilidad y el volumen de entrenamiento de los SQL standards en GPT/Claude aseguran manipulaciones de alto rango dinámicas eficaces.
- **Vector Search RAG:** `pgvector` empotrado en PostgreSQL como la norma general, reduciendo así la carga cognitiva necesaria para operar sistemas de almacenamiento vectoriales externos y unificando el gobierno de persistencia y metadatos.
- **Alternativas Especializadas (Masivas):** Para billones de vectores o inferencias dedicadas, recurrir a bases como Pinecone o Milvus.
- **ORM / Query Builders:**
  - En TypeScript: Prisma o Drizzle.
  - En Python: SQLAlchemy. (Gran capacidad autónoma proveyendo migraciones correctas con los LLMs).

---

## 🤖 4. Arquitectura LLM y Orquestación de Flujos

- **Framework de Agentes (Base):** **OpenClaw** (https://docs.openclaw.ai/) es el estándar y núcleo fundacional definido para la orquestación. Actúa como gateway centralizado de multi-agentes proactivos, manejo de persistencia local (memoria), integración multi-canal (WhatsApp, Slack, Discord) y ejecución de módulos de herramientas conectadas (*AgentSkills*).
- **Modelos de Lenguaje Fundacionales (LLMs):** El sistema es agnóstico pero se trabajará operativamente con los modelos de frontera más capacitados en razonamiento y tool-calling:
  - Familia **Gemini** (Google).
  - Familia **GPT** (OpenAI).
  - Familia **Claude** (Anthropic).
  - **Modelos Chinos de Frontera** (DeepSeek, Qwen) por su eficiencia de costo/razonamiento superior en inferencias lógicas rigurosas.
- **Embeddings:** Se estandariza el uso exclusivo de los modelos de embeddings de **OpenAI** (ej. `text-embedding-3-small` / `large`) acoplados con la vectorización gestionada internamente por la capa de datos.
- **Integraciones Secundarias:** En compatibilidad transversal con OpenClaw, se contemplan componentes de Vercel AI SDK para UI generativa en frontend, o bibliotecas satélite exclusivas como LlamaIndex para RAG granular.

---

## 🛠️ 5. Infraestructura y DevOps (Capa Declarativa y Local)

Suscrito bajo directivos de persistencia local controlada y despliegue por contenedores:

- **Empaquetado y Aislamiento:** Uso obligatorio de **Docker** e imágenes contenerizadas para garantizar la portabilidad global y un entorno de ejecución homologado en cualquier ecosistema.
- **Infraestructura Base:** Despliegues auto-alojados (*Self-hosted*) en servidores remotos utilizando distribuciones de base Linux **Ubuntu**. Se utilizarán instancias VPS o servidores dedicados, con especial preferencia por el proveedor de alojamiento **Hetzner**, aprovechando su extrema eficiencia de costos y alto rendimiento de hardware "bare metal" virtualizado.
- **Soberanía y Entorno de Ejecución:** El diseño prioriza el control completo sobre los datos de la IA, operando el *Gateway* de OpenClaw y las APIs dentro del perímetro seguro de los servidores en Hetzner.
- **Ecosistema GitHub (Repositorio de Verdad):** Se estandariza **GitHub** como la única fuente de la verdad para el ciclo de vida del agente. Todas las iteraciones del LLM y los *AgentSkills* operan sobre el repositorio, aprovechando al máximo la sobre-representación de código de GitHub en el entrenamiento de los propios modelos para auto-corrección.
- **Integración y Despliegue Continuo (CI/CD):** 
  - **GitHub Actions:** Orquestador primario e indispensable para testeo automatizado de alucinaciones sintácticas, linting, y escaneo de vulnerabilidades en cada *Pull Request*.
  - **GitOps y Despliegue Automatizado:** Las implementaciones en infraestructura Ubuntu (Hetzner) se rigen por un control *drift* estricto de Git. Herramientas complementarias sugeridas como **Argo CD** mantendrán la sincronización declarativa continua entre el repositorio de GitHub y los contenedores productivos de OpenClaw.

---

## 🛡️ 6. Seguridad y Observabilidad de Agentes en Producción

El ecosistema actual requiere instrumentación específica superior al MLOps tradicional para el control iterativo e integraciones de herramientas asíncronas de un agente como OpenClaw:

- **Observabilidad General y Tracing (AI-Native):** Debe adoptarse **Langfuse** o **LangSmith** para instrumentar métricas de caja blanca en las cadenas cognitivas: perfilar de forma forense el llamado a funciones (*AgentSkills*), medir latencias de RAG y evaluar el costo económico desglosado por sesión multi-agente en tiempo real.
- **Estándares Abiertos (OpenTelemetry):** Proyectar y enganchar las telemetrías nativas de los LLMs con herramientas adaptables al estándar **OpenTelemetry** (por ejemplo Traceloop OpenLLMetry) para correlacionar la calidad de la IA con el rendimiento de red y del hardware subyacente del servidor Ubuntu en dashboards unificados de Grafana/Datadog.
- **Evaluación de Calidad Continua:** Implementar validación analítica sistemática (LLM-as-a-judge u otros métodos) sobre las fallas "silenciosas" tales como alucinaciones persistentes (con herramientas en vanguardia metodológica como **TruLens** o **Arize Phoenix** / Arize AI) antes de consolidar agentes al plano de ambiente principal.
- **Seguridad Dinámica:** Alineación estricta con el top de amenazas OWASP for LLMs:
  - Listas blancas rígidas (*allowlists*) de las acciones del agente para blindar estrictamente lo que puede ejecutar cada instancia (Especial foco sobre privilegios de sistema).
  - Sanitización estandarizada de todos los outputs cruzados previo a que un framework ejecutor desencadene una acción real de OS Shell u operacion vía web.
