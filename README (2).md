# AIOS Ubuntu

AIOS Ubuntu is a local-first, agent-driven operating system prototype for Ubuntu 22.04 LTS.  
It combines natural-language and voice interaction, local model runtimes, a secure Rust execution layer,
a Python planning/runtime layer, and Tauri/React desktop UI.

## Goals

- Natural language and voice control for daily system tasks
- Secure, auditable, rollback-capable tool execution
- Local-first model inference for privacy
- Extensible tool registry and SDK for third-party plugins
- Ubuntu desktop integration with systemd, AppArmor, and Polkit

## Architecture

The repository is a monorepo with four major domains:

- `apps/`: Tauri/React desktop applications
- `services/`: Python API, planner, model, memory, and RAG services
- `crates/`: Rust daemons, executors, policy, audit, sandbox, and native tools
- `registry/`: declarative tool and permission manifests

## Layers

1. Language Layer  
   Natural language input, voice input, intent parsing, parameter extraction, clarification.

2. Interaction Layer  
   Command palette, NL shell, status panel, settings, permissions UI, task timeline.

3. Planning Layer  
   Intent parsing, tool selection, DAG planning, retries, human approval, schema constraints.

4. Execution Layer  
   Tool registry, permission validation, dry-run, undo, rollback, sandboxed execution.

5. Memory & RAG Layer  
   Session memory, episodic memory, vector search, BM25, document ingestion, indexing.

6. Model Runtime Layer  
   LLM, ASR, TTS, embeddings, reranker, OCR, optional VLM.

7. OS Integration & Security Layer  
   systemd, AppArmor, Polkit, DBus, local sockets, audit log, confirmation rules.

8. Physical Layer  
   CPU, GPU, microphone, speakers, file system, desktop environment, network, local apps.

## Repository status

This repository is a **full scaffold** for the target system:

- directory tree implemented
- core bootstrap files included
- sample services, configs, manifests, and tests included
- many modules are stubs/placeholders for later implementation
- model folders are placeholders only; actual weights are not included

## Quick start

### 1. Create Python environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements/dev.txt
```

### 2. Start the minimal Python stack

```bash
bash scripts/start_local_stack.sh
```

### 3. Run smoke tests

```bash
python scripts/smoke_test.py
```

### 4. Inspect the tool registry

```bash
ls registry/tools
cat registry/tools/fs.merge_pdf.yaml
```

## Minimal execution flow

Example user request:

> Merge all PDFs on Desktop modified within the last 7 days and add a cover page.

Flow:

1. `apps/command-palette` sends a request to `services/api-gateway`
2. `services/planner-service` creates a structured plan
3. `tool-executor` validates the tool manifest and permission scope
4. `policy-engine` decides whether confirmation is required
5. `file-tools` performs the operation
6. `auditd` persists the audit event and rollback metadata
7. UI receives status updates and offers undo where applicable

## Key folders

### `apps/`
Desktop UX:
- `command-palette/`
- `nl-shell/`
- `status-panel/`
- `settings-ui/`

### `services/`
Python runtime:
- `api-gateway/`
- `planner-service/`
- `model-router/`
- `llm-cpu-service/`
- `llm-gpu-service/`
- `asr-service/`
- `tts-service/`
- `embedding-service/`
- `reranker-service/`
- `ocr-service/`
- `vlm-service/`
- `rag-service/`
- `memory-service/`
- `indexer-service/`
- `session-service/`

### `crates/`
Rust runtime:
- `agentd/`
- `tool-executor/`
- `policy-engine/`
- `auditd/`
- `rollback-engine/`
- `sandbox-runner/`
- `file-tools/`
- `media-tools/`
- `system-tools/`
- `app-connectors/`

### `registry/`
Declarative manifests:
- `schemas/`
- `tools/`
- `permissions/`
- `ui-hints/`
- `examples/`

### `models/`
Local model storage:
- `llm/`
- `asr/`
- `tts/`
- `embedding/`
- `reranker/`
- `ocr/`
- `vlm/`

## Tool registry philosophy

The LLM is **never allowed** to execute arbitrary shell commands directly.
Every capability must be declared in the tool registry with:

- tool id
- description
- input schema
- permission requirements
- risk level
- dry-run support
- rollback mode
- UI confirmation metadata

See `registry/tools/fs.merge_pdf.yaml`.

## Suggested first implementation order

1. `agentd`
2. `tool-executor`
3. `policy-engine`
4. `registry/`
5. `services/api-gateway`
6. `services/planner-service`
7. `crates/file-tools`
8. `apps/command-palette`

## Packaging

This scaffold already contains:
- `infra/systemd/`
- `infra/apparmor/`
- `infra/polkit/`
- `infra/deb/`
- `infra/flatpak/`

You can later convert this into a runnable Ubuntu package.

## Roadmap

- v0.1: local planner + registry + file tools + command palette
- v0.2: ASR + TTS + task timeline + audit viewer
- v0.3: RAG + memory + OCR + rollback
- v0.4: plugin SDK + packaging + richer system integrations
- v0.5: optional VLM for desktop/screenshot understanding

## Notes

- This scaffold is intentionally explicit and modular.
- Many files are starter implementations or placeholders.
- Actual production hardening will require deeper security work, testing, and packaging polish.
