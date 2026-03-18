# AIOS
一、推荐总架构

我建议你做成：

Rust：系统守护进程、权限控制、工具执行、安全审计、IPC

Python：Planner / Agent / RAG / Memory / 模型编排

TypeScript + Tauri/React：命令面板、状态面板、权限弹窗、设置页

本地模型服务：llama.cpp / vLLM / faster-whisper / Piper / embedding / OCR

通信方式：

外部统一入口：HTTP API Gateway

本地高可信通信：Unix Socket / gRPC

UI 与本地守护进程：Tauri IPC

审计与状态：SQLite + JSONL

二、分层设计（从上到下）
1）Language Layer（语言层）

负责把用户输入变成结构化意图。

包含：

自然语言输入

语音输入

命令补全

意图解析

参数抽取

多轮澄清

对应模块：

planner/intent_parser

planner/schema_guard

services/asr-service

apps/command-palette

2）Interaction Layer（交互层）

负责用户看得见、点得到、确认得了的界面。

包含：

全局命令面板 Super+K

NL-Shell

权限确认弹窗

任务进度面板

托盘图标

历史任务与审计查看器

对应模块：

apps/command-palette

apps/nl-shell

apps/status-panel

apps/settings-ui

3）Planning Layer（规划层）

负责把一句话拆成计划、DAG、步骤序列。

包含：

Intent Parsing

Tool Selection

DAG Planning

Retry / Fallback

Human-in-the-loop Approval

JSON Schema 强约束输出

对应模块：

services/planner-service

services/model-router

services/session-service

4）Execution Layer（执行层）

负责真正调用工具，操作文件、应用、通知、压缩、OCR 等。

包含：

Tool Registry

Tool Executor

Permission Check

Dry-run

Undo / Rollback

Sandbox 执行

对应模块：

crates/tool-executor

crates/policy-engine

crates/rollback-engine

registry/tools

registry/policies

5）Memory & RAG Layer（记忆与检索层）

负责短期上下文、长期记忆、文档索引、本地知识库。

包含：

Session Memory

Episodic Memory

Semantic Retrieval

Hybrid Search（BM25 + Vector）

Knowledge Ingestion

对应模块：

services/rag-service

services/memory-service

services/indexer-service

6）Model Runtime Layer（模型运行时层）

负责所有模型服务。

包含：

LLM

ASR

TTS

Embedding

Reranker

OCR

可选 VLM

对应模块：

services/llm-cpu-service

services/llm-gpu-service

services/asr-service

services/tts-service

services/embedding-service

services/reranker-service

services/ocr-service

services/vlm-service

7）OS Integration & Security Layer（系统集成与安全层）

负责和 Ubuntu 系统深度集成，并控制风险。

包含：

systemd

AppArmor

Polkit

DBus

Flatpak/App 沙箱

权限令牌

审计日志

高危操作二次确认

对应模块：

crates/agentd

infra/systemd

infra/apparmor

infra/polkit

crates/auditd

8）Physical Layer（物理层）

真正的底层资源。

包含：

CPU / GPU

麦克风 / 扬声器

文件系统

桌面环境

网络

剪贴板

本地应用程序

摄像头（后续）

三、完整代码结构（推荐版本）
aios-ubuntu/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ .env.example
├─ docker-compose.yml
├─ Makefile
├─ Cargo.toml
├─ pyproject.toml
├─ pnpm-workspace.yaml
├─ requirements/
│  ├─ base.txt
│  ├─ dev.txt
│  ├─ planner.txt
│  ├─ rag.txt
│  └─ models.txt
│
├─ apps/                             # 前端/UI
│  ├─ command-palette/               # 全局命令面板 Super+K
│  │  ├─ package.json
│  │  ├─ tauri.conf.json
│  │  ├─ src/
│  │  │  ├─ main.tsx
│  │  │  ├─ App.tsx
│  │  │  ├─ components/
│  │  │  │  ├─ CommandInput.tsx
│  │  │  │  ├─ SuggestionList.tsx
│  │  │  │  ├─ PermissionCard.tsx
│  │  │  │  ├─ ProgressTimeline.tsx
│  │  │  │  └─ ResultPreview.tsx
│  │  │  ├─ pages/
│  │  │  │  ├─ Home.tsx
│  │  │  │  ├─ Confirm.tsx
│  │  │  │  ├─ Running.tsx
│  │  │  │  └─ Done.tsx
│  │  │  ├─ store/
│  │  │  │  ├─ session.ts
│  │  │  │  ├─ task.ts
│  │  │  │  └─ settings.ts
│  │  │  ├─ hooks/
│  │  │  │  ├─ useAgentStream.ts
│  │  │  │  ├─ useHotkey.ts
│  │  │  │  └─ usePermissionFlow.ts
│  │  │  ├─ services/
│  │  │  │  ├─ api.ts
│  │  │  │  ├─ events.ts
│  │  │  │  └─ ipc.ts
│  │  │  └─ styles/
│  │  │     └─ globals.css
│  │  └─ src-tauri/
│  │     ├─ src/
│  │     │  ├─ main.rs
│  │     │  ├─ hotkey.rs
│  │     │  ├─ tray.rs
│  │     │  ├─ window.rs
│  │     │  ├─ ipc.rs
│  │     │  └─ permissions.rs
│  │     └─ Cargo.toml
│  │
│  ├─ nl-shell/                      # 自然语言 Shell
│  │  ├─ package.json
│  │  ├─ src/
│  │  │  ├─ main.tsx
│  │  │  ├─ TerminalView.tsx
│  │  │  ├─ DryRunPanel.tsx
│  │  │  ├─ CommandDiff.tsx
│  │  │  └─ ShellHistory.tsx
│  │  └─ src-tauri/
│  │     └─ src/main.rs
│  │
│  ├─ status-panel/                  # 状态面板/托盘
│  │  ├─ package.json
│  │  ├─ src/
│  │  │  ├─ main.tsx
│  │  │  ├─ TaskStatusCard.tsx
│  │  │  ├─ ModelStatusCard.tsx
│  │  │  ├─ AuditFeed.tsx
│  │  │  └─ ResourceUsage.tsx
│  │  └─ src-tauri/
│  │     └─ src/main.rs
│  │
│  └─ settings-ui/
│     ├─ package.json
│     ├─ src/
│     │  ├─ main.tsx
│     │  ├─ pages/
│     │  │  ├─ Models.tsx
│     │  │  ├─ Tools.tsx
│     │  │  ├─ Permissions.tsx
│     │  │  ├─ Voices.tsx
│     │  │  └─ Audit.tsx
│     │  └─ components/
│     │     ├─ ModelSelector.tsx
│     │     ├─ ToolToggle.tsx
│     │     ├─ PermissionEditor.tsx
│     │     └─ VoicePreview.tsx
│     └─ src-tauri/
│        └─ src/main.rs
│
├─ services/                         # Python 服务层
│  ├─ api-gateway/                   # 统一入口
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ routes/
│  │  │  │  ├─ chat.py
│  │  │  │  ├─ speech.py
│  │  │  │  ├─ tools.py
│  │  │  │  ├─ tasks.py
│  │  │  │  ├─ memory.py
│  │  │  │  └─ audit.py
│  │  │  ├─ middleware/
│  │  │  │  ├─ auth.py
│  │  │  │  ├─ tracing.py
│  │  │  │  └─ rate_limit.py
│  │  │  ├─ schemas/
│  │  │  │  ├─ request.py
│  │  │  │  ├─ response.py
│  │  │  │  └─ events.py
│  │  │  └─ deps.py
│  │  └─ tests/
│  │
│  ├─ planner-service/               # Agent / Planner / DAG
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ planner/
│  │  │  │  ├─ orchestrator.py
│  │  │  │  ├─ intent_parser.py
│  │  │  │  ├─ task_decomposer.py
│  │  │  │  ├─ dag_builder.py
│  │  │  │  ├─ executor.py
│  │  │  │  ├─ retry_policy.py
│  │  │  │  ├─ approval_gate.py
│  │  │  │  ├─ schema_guard.py
│  │  │  │  ├─ prompt_builder.py
│  │  │  │  └─ result_summarizer.py
│  │  │  ├─ state/
│  │  │  │  ├─ session_state.py
│  │  │  │  ├─ task_state.py
│  │  │  │  └─ memory_state.py
│  │  │  ├─ integrations/
│  │  │  │  ├─ tool_client.py
│  │  │  │  ├─ llm_client.py
│  │  │  │  ├─ rag_client.py
│  │  │  │  └─ audit_client.py
│  │  │  ├─ policies/
│  │  │  │  ├─ high_risk_rules.py
│  │  │  │  └─ auto_confirm_rules.py
│  │  │  └─ schemas/
│  │  │     ├─ plan.schema.json
│  │  │     ├─ tool_call.schema.json
│  │  │     ├─ approval.schema.json
│  │  │     └─ result.schema.json
│  │  └─ tests/
│  │
│  ├─ model-router/                  # 模型路由层
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ router.py
│  │  │  ├─ profiles.py
│  │  │  ├─ capabilities.py
│  │  │  ├─ cost_policy.py
│  │  │  ├─ latency_policy.py
│  │  │  ├─ fallbacks.py
│  │  │  └─ healthcheck.py
│  │  └─ tests/
│  │
│  ├─ llm-cpu-service/               # llama.cpp
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ server.py
│  │  │  ├─ adapters/
│  │  │  │  └─ llama_cpp_adapter.py
│  │  │  ├─ prompt/
│  │  │  │  ├─ system.txt
│  │  │  │  └─ planner.txt
│  │  │  └─ schemas/
│  │  └─ tests/
│  │
│  ├─ llm-gpu-service/               # vLLM
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ server.py
│  │  │  ├─ adapters/
│  │  │  │  └─ vllm_adapter.py
│  │  │  └─ batching.py
│  │  └─ tests/
│  │
│  ├─ asr-service/                   # faster-whisper
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ transcribe.py
│  │  │  ├─ vad.py
│  │  │  ├─ diarization.py
│  │  │  └─ audio_preprocess.py
│  │  └─ tests/
│  │
│  ├─ tts-service/                   # Piper
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ synthesize.py
│  │  │  ├─ voices.py
│  │  │  ├─ cache.py
│  │  │  └─ audio_postprocess.py
│  │  └─ tests/
│  │
│  ├─ embedding-service/             # bge-m3 / e5-mistral
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ embed.py
│  │  │  ├─ chunking.py
│  │  │  └─ normalize.py
│  │  └─ tests/
│  │
│  ├─ reranker-service/              # 可选
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  └─ rerank.py
│  │  └─ tests/
│  │
│  ├─ ocr-service/                   # Tesseract OCR
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ extract.py
│  │  │  ├─ pdf_ocr.py
│  │  │  ├─ image_ocr.py
│  │  │  └─ layout.py
│  │  └─ tests/
│  │
│  ├─ vlm-service/                   # 可选：LLaVA/InternVL
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ caption.py
│  │  │  ├─ image_understanding.py
│  │  │  └─ screen_parse.py
│  │  └─ tests/
│  │
│  ├─ rag-service/
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ ingest.py
│  │  │  ├─ retrieve.py
│  │  │  ├─ hybrid_search.py
│  │  │  ├─ vector_store.py
│  │  │  ├─ bm25_store.py
│  │  │  ├─ citation_builder.py
│  │  │  └─ dedup.py
│  │  └─ tests/
│  │
│  ├─ memory-service/
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ short_term.py
│  │  │  ├─ long_term.py
│  │  │  ├─ episodic.py
│  │  │  ├─ preference_store.py
│  │  │  └─ recall.py
│  │  └─ tests/
│  │
│  ├─ indexer-service/
│  │  ├─ app/
│  │  │  ├─ main.py
│  │  │  ├─ file_watch.py
│  │  │  ├─ parser.py
│  │  │  ├─ chunker.py
│  │  │  └─ schedule_reindex.py
│  │  └─ tests/
│  │
│  └─ session-service/
│     ├─ app/
│     │  ├─ main.py
│     │  ├─ sessions.py
│     │  ├─ tasks.py
│     │  ├─ events.py
│     │  └─ stream.py
│     └─ tests/
│
├─ crates/                           # Rust 核心能力
│  ├─ common/
│  │  ├─ src/
│  │  │  ├─ lib.rs
│  │  │  ├─ errors.rs
│  │  │  ├─ types.rs
│  │  │  ├─ config.rs
│  │  │  ├─ tracing.rs
│  │  │  └─ utils.rs
│  │  └─ Cargo.toml
│  │
│  ├─ ipc-proto/
│  │  ├─ proto/
│  │  │  ├─ tool.proto
│  │  │  ├─ audit.proto
│  │  │  └─ session.proto
│  │  ├─ src/lib.rs
│  │  └─ Cargo.toml
│  │
│  ├─ agentd/                        # 本地守护进程
│  │  ├─ src/
│  │  │  ├─ main.rs
│  │  │  ├─ daemon.rs
│  │  │  ├─ config.rs
│  │  │  ├─ socket.rs
│  │  │  ├─ health.rs
│  │  │  ├─ service_registry.rs
│  │  │  ├─ task_supervisor.rs
│  │  │  ├─ shutdown.rs
│  │  │  └─ metrics.rs
│  │  └─ Cargo.toml
│  │
│  ├─ tool-executor/
│  │  ├─ src/
│  │  │  ├─ main.rs
│  │  │  ├─ executor.rs
│  │  │  ├─ registry.rs
│  │  │  ├─ validator.rs
│  │  │  ├─ dispatcher.rs
│  │  │  ├─ dry_run.rs
│  │  │  ├─ result.rs
│  │  │  └─ manifest.rs
│  │  └─ Cargo.toml
│  │
│  ├─ policy-engine/
│  │  ├─ src/
│  │  │  ├─ lib.rs
│  │  │  ├─ permission.rs
│  │  │  ├─ token.rs
│  │  │  ├─ resource_scope.rs
│  │  │  ├─ risk_level.rs
│  │  │  ├─ confirmation.rs
│  │  │  └─ policy_eval.rs
│  │  └─ Cargo.toml
│  │
│  ├─ auditd/
│  │  ├─ src/
│  │  │  ├─ main.rs
│  │  │  ├─ writer.rs
│  │  │  ├─ journal.rs
│  │  │  ├─ sqlite_sink.rs
│  │  │  ├─ jsonl_sink.rs
│  │  │  ├─ redaction.rs
│  │  │  └─ search.rs
│  │  └─ Cargo.toml
│  │
│  ├─ rollback-engine/
│  │  ├─ src/
│  │  │  ├─ lib.rs
│  │  │  ├─ rename_undo.rs
│  │  │  ├─ trash_restore.rs
│  │  │  ├─ archive_undo.rs
│  │  │  ├─ mapping_store.rs
│  │  │  └─ transaction.rs
│  │  └─ Cargo.toml
│  │
│  ├─ sandbox-runner/
│  │  ├─ src/
│  │  │  ├─ main.rs
│  │  │  ├─ process.rs
│  │  │  ├─ flatpak.rs
│  │  │  ├─ namespace.rs
│  │  │  └─ tempfs.rs
│  │  └─ Cargo.toml
│  │
│  ├─ file-tools/
│  │  ├─ src/
│  │  │  ├─ lib.rs
│  │  │  ├─ search.rs
│  │  │  ├─ rename.rs
│  │  │  ├─ merge_pdf.rs
│  │  │  ├─ compress.rs
│  │  │  ├─ move_to_trash.rs
│  │  │  ├─ copy.rs
│  │  │  └─ metadata.rs
│  │  └─ Cargo.toml
│  │
│  ├─ media-tools/
│  │  ├─ src/
│  │  │  ├─ lib.rs
│  │  │  ├─ play_audio.rs
│  │  │  ├─ transcode.rs
│  │  │  ├─ image_convert.rs
│  │  │  └─ thumbnail.rs
│  │  └─ Cargo.toml
│  │
│  ├─ system-tools/
│  │  ├─ src/
│  │  │  ├─ lib.rs
│  │  │  ├─ notify.rs
│  │  │  ├─ open_app.rs
│  │  │  ├─ clipboard.rs
│  │  │  ├─ browser.rs
│  │  │  ├─ terminal.rs
│  │  │  ├─ screenshot.rs
│  │  │  └─ dbus.rs
│  │  └─ Cargo.toml
│  │
│  └─ app-connectors/
│     ├─ src/
│     │  ├─ lib.rs
│     │  ├─ thunderbird.rs
│     │  ├─ libreoffice.rs
│     │  ├─ calendar.rs
│     │  └─ music_player.rs
│     └─ Cargo.toml
│
├─ registry/                         # 工具声明中心
│  ├─ schemas/
│  │  ├─ tool.schema.json
│  │  ├─ permission.schema.json
│  │  ├─ resource.schema.json
│  │  ├─ ui.schema.json
│  │  └─ rollback.schema.json
│  │
│  ├─ tools/
│  │  ├─ fs.search.yaml
│  │  ├─ fs.rename_batch.yaml
│  │  ├─ fs.merge_pdf.yaml
│  │  ├─ fs.compress.yaml
│  │  ├─ media.play_audio.yaml
│  │  ├─ sys.notify.yaml
│  │  ├─ sys.open_app.yaml
│  │  ├─ sys.clipboard_read.yaml
│  │  ├─ ocr.extract_text.yaml
│  │  ├─ rag.search_docs.yaml
│  │  └─ mail.compose_draft.yaml
│  │
│  ├─ permissions/
│  │  ├─ default.yaml
│  │  ├─ high_risk.yaml
│  │  ├─ fs_scopes.yaml
│  │  └─ app_scopes.yaml
│  │
│  ├─ ui-hints/
│  │  ├─ confirm_templates.yaml
│  │  ├─ risk_labels.yaml
│  │  └─ tool_icons.yaml
│  │
│  └─ examples/
│     ├─ third_party_translate.yaml
│     └─ third_party_calendar.yaml
│
├─ sdk/
│  ├─ python/
│  │  ├─ aios_sdk/
│  │  │  ├─ __init__.py
│  │  │  ├─ tool.py
│  │  │  ├─ client.py
│  │  │  ├─ permissions.py
│  │  │  ├─ decorators.py
│  │  │  └─ schemas.py
│  │  ├─ examples/
│  │  │  ├─ translator_tool.py
│  │  │  └─ calendar_tool.py
│  │  └─ pyproject.toml
│  │
│  └─ typescript/
│     ├─ src/
│     │  ├─ index.ts
│     │  ├─ defineTool.ts
│     │  ├─ client.ts
│     │  ├─ permissions.ts
│     │  └─ schemas.ts
│     ├─ examples/
│     │  ├─ translatorTool.ts
│     │  └─ reminderTool.ts
│     └─ package.json
│
├─ models/                           # 本地模型文件
│  ├─ llm/
│  │  ├─ qwen2.5-7b-instruct/
│  │  ├─ qwen2.5-14b-instruct/
│  │  ├─ llama-3.1-8b-instruct/
│  │  └─ mistral-small-instruct/
│  │
│  ├─ asr/
│  │  ├─ faster-whisper-small/
│  │  ├─ faster-whisper-medium/
│  │  └─ faster-whisper-large-v3/
│  │
│  ├─ tts/
│  │  ├─ piper-en_US/
│  │  ├─ piper-zh_CN/
│  │  └─ piper-de_DE/
│  │
│  ├─ embedding/
│  │  ├─ bge-m3/
│  │  └─ e5-mistral-7b-instruct/
│  │
│  ├─ reranker/
│  │  └─ bge-reranker-v2-m3/
│  │
│  ├─ ocr/
│  │  ├─ tesseract/
│  │  ├─ eng.traineddata
│  │  ├─ chi_sim.traineddata
│  │  └─ deu.traineddata
│  │
│  └─ vlm/
│     ├─ llava/
│     └─ internvl/
│
├─ configs/
│  ├─ dev/
│  │  ├─ gateway.yaml
│  │  ├─ planner.yaml
│  │  ├─ models.yaml
│  │  ├─ tools.yaml
│  │  └─ logging.yaml
│  │
│  ├─ prod/
│  │  ├─ gateway.yaml
│  │  ├─ planner.yaml
│  │  ├─ models.yaml
│  │  ├─ tools.yaml
│  │  └─ logging.yaml
│  │
│  ├─ routing/
│  │  ├─ llm_profiles.yaml
│  │  ├─ embedding_profiles.yaml
│  │  └─ fallback_chain.yaml
│  │
│  ├─ prompts/
│  │  ├─ planner.system.txt
│  │  ├─ intent.system.txt
│  │  ├─ approval.system.txt
│  │  └─ summarizer.system.txt
│  │
│  └─ security/
│     ├─ risk_matrix.yaml
│     ├─ confirmation_rules.yaml
│     ├─ path_allowlist.yaml
│     └─ token_ttl.yaml
│
├─ infra/
│  ├─ docker/
│  │  ├─ gateway.Dockerfile
│  │  ├─ planner.Dockerfile
│  │  ├─ asr.Dockerfile
│  │  ├─ tts.Dockerfile
│  │  ├─ embed.Dockerfile
│  │  └─ ocr.Dockerfile
│  │
│  ├─ systemd/
│  │  ├─ aios-agentd.service
│  │  ├─ aios-gateway.service
│  │  ├─ aios-planner.service
│  │  ├─ aios-asr.service
│  │  ├─ aios-tts.service
│  │  └─ aios-rag.service
│  │
│  ├─ apparmor/
│  │  ├─ aios-agentd.profile
│  │  ├─ tool-executor.profile
│  │  └─ sandbox-runner.profile
│  │
│  ├─ polkit/
│  │  └─ org.aios.permissions.policy
│  │
│  ├─ deb/
│  │  ├─ control
│  │  ├─ postinst
│  │  └─ prerm
│  │
│  └─ flatpak/
│     ├─ org.aios.App.yaml
│     └─ permissions.json
│
├─ data/
│  ├─ sqlite/
│  │  ├─ audit.db
│  │  ├─ sessions.db
│  │  ├─ memory.db
│  │  └─ rag.db
│  │
│  ├─ vector/
│  │  ├─ faiss/
│  │  └─ sqlite-vec/
│  │
│  ├─ bm25/
│  ├─ cache/
│  ├─ tmp/
│  ├─ trash/
│  ├─ task-artifacts/
│  └─ logs/
│     ├─ audit/
│     ├─ planner/
│     ├─ tools/
│     └─ models/
│
├─ docs/
│  ├─ architecture/
│  │  ├─ system-overview.md
│  │  ├─ service-topology.md
│  │  ├─ tool-lifecycle.md
│  │  ├─ permission-model.md
│  │  └─ rollback-design.md
│  │
│  ├─ developer/
│  │  ├─ quickstart.md
│  │  ├─ add-a-tool.md
│  │  ├─ add-a-model.md
│  │  ├─ add-a-ui-plugin.md
│  │  └─ sdk-guide.md
│  │
│  ├─ user/
│  │  ├─ install.md
│  │  ├─ using-command-palette.md
│  │  ├─ voice-control.md
│  │  ├─ permissions.md
│  │  └─ audit-viewer.md
│  │
│  └─ examples/
│     ├─ merge-pdf-workflow.md
│     ├─ batch-rename-workflow.md
│     └─ voice-command-workflow.md
│
├─ scripts/
│  ├─ bootstrap_ubuntu.sh
│  ├─ install_cuda.sh
│  ├─ download_models.sh
│  ├─ start_local_stack.sh
│  ├─ stop_local_stack.sh
│  ├─ seed_registry.py
│  ├─ warmup_models.py
│  ├─ reindex_docs.py
│  └─ smoke_test.py
│
├─ tests/
│  ├─ e2e/
│  │  ├─ test_merge_pdf.py
│  │  ├─ test_batch_rename.py
│  │  ├─ test_voice_command.py
│  │  └─ test_permission_flow.py
│  │
│  ├─ integration/
│  │  ├─ test_gateway_planner.py
│  │  ├─ test_planner_executor.py
│  │  ├─ test_rag_pipeline.py
│  │  └─ test_audit_rollback.py
│  │
│  └─ fixtures/
│     ├─ sample_pdfs/
│     ├─ sample_audio/
│     ├─ sample_images/
│     └─ tool_registry/
│
└─ examples/
   ├─ sample_tasks/
   │  ├─ merge_desktop_pdfs.json
   │  ├─ compress_project_files.json
   │  └─ summarize_local_docs.json
   ├─ tool_manifests/
   └─ sdk_plugins/
四、你这个 AI OS 的“所有模型”应该怎么放
1）LLM 层

负责推理、规划、总结、参数补全。

建议分两类：

轻量本地 LLM

用于：

快速意图解析

工具参数补全

命令建议

短文本总结

目录：

models/llm/qwen2.5-7b-instruct/

models/llm/llama-3.1-8b-instruct/

服务：

services/llm-cpu-service

services/llm-gpu-service

中型规划 LLM

用于：

DAG 规划

多步任务

工具链编排

长上下文 RAG 问答

目录：

models/llm/qwen2.5-14b-instruct/

2）ASR 模型

负责语音识别。

目录：

models/asr/faster-whisper-small/

models/asr/faster-whisper-medium/

models/asr/faster-whisper-large-v3/

服务：

services/asr-service

3）TTS 模型

负责语音播报。

目录：

models/tts/piper-en_US/

models/tts/piper-zh_CN/

models/tts/piper-de_DE/

服务：

services/tts-service

4）Embedding 模型

负责本地知识库与语义检索。

目录：

models/embedding/bge-m3/

models/embedding/e5-mistral-7b-instruct/

服务：

services/embedding-service

5）Reranker 模型

负责二阶段重排，提高 RAG 质量。

目录：

models/reranker/bge-reranker-v2-m3/

服务：

services/reranker-service

6）OCR 模型

负责图片/PDF 文字提取。

目录：

models/ocr/tesseract/

服务：

services/ocr-service

7）VLM（可选）

后期做多模态桌面理解时再上。

目录：

models/vlm/llava/

models/vlm/internvl/

服务：

services/vlm-service

用途：

看懂截图

看懂界面

解析桌面状态

视觉辅助自动化

五、核心服务之间的调用关系

用户一句话：

“把桌面上 7 天内的 PDF 合并并加目录页”

系统流程应该是：

Command Palette / Voice Input
        ↓
API Gateway
        ↓
Planner Service
  ├─ 调 Model Router 选 LLM
  ├─ 调 RAG Service（必要时）
  ├─ 生成严格 JSON Plan
  └─ 判断是否需要权限确认
        ↓
Approval Gate
        ↓
Tool Executor (Rust)
  ├─ 读取 Tool Registry
  ├─ 检查参数 Schema
  ├─ 检查权限 Policy
  ├─ Dry-run 输出预演结果
  ├─ 用户确认
  └─ 真正执行
        ↓
Auditd
  ├─ 记录调用链
  ├─ 参数
  ├─ 文件变更
  └─ rollback 映射
        ↓
UI 状态回流
  ├─ Running
  ├─ Completed
  └─ Undo Available
六、最关键的几个模块职责
agentd

它是 AI OS 的本地总控守护进程。

负责：

管理本地所有服务状态

统一健康检查

给 UI 提供状态流

调度 Planner / Executor

维护本地 socket

处理开机自启

tool-executor

这是整个系统安全边界里最重要的一层。

它不是“执行 shell 字符串”，而是：

从 registry 找到工具定义

校验输入参数

检查权限范围

做 dry-run

执行具体 Rust 工具函数

返回结构化结果

写审计日志

保存回滚映射

planner-service

这是 AI 大脑，不直接碰文件系统。

它只做：

理解意图

生成计划

挑选工具

组织依赖关系

处理重试

要不要让人确认

它不能直接 rm、mv、rename。
真正操作必须走 tool-executor。

registry/

这是整个系统的“能力声明中心”。

所有工具都得声明：

id

描述

参数 schema

权限需求

风险等级

是否支持 dry-run

是否支持 rollback

UI 提示模板

七、一个 Tool Registry 的典型 YAML 结构

你这个项目里，工具不要写死在 prompt 里，而是一定要声明化。

例如：

id: fs.merge_pdf
name: Merge PDF Files
description: Merge multiple PDF files into one output document
version: 1.0.0
executor: rust
entrypoint: file_tools::merge_pdf
risk_level: medium

input_schema:
  type: object
  properties:
    input_files:
      type: array
      items:
        type: string
    output_file:
      type: string
    add_toc_page:
      type: boolean
  required: [input_files, output_file]

permissions:
  - type: fs.read
    scope: user_selected
  - type: fs.write
    scope: user_selected

dry_run: true

rollback:
  supported: true
  mode: delete_created_file

ui:
  confirm_title: "Merge PDF files?"
  confirm_message: "AI will merge selected PDF files and create a new output file."
  show_diff: false
八、建议的首批内置工具

你第一版先做这 12 个最值钱：

文件类

fs.search

fs.rename_batch

fs.merge_pdf

fs.compress

fs.copy

fs.move_to_trash

系统类

sys.notify

sys.open_app

sys.clipboard_read

sys.clipboard_write

AI 增强类

ocr.extract_text

rag.search_docs

再往后加：

mail.compose_draft

calendar.create_event

browser.open_url

media.play_audio

九、数据库与持久化怎么分
SQLite

用于：

审计日志

会话历史

偏好设置

工具调用记录

rollback 映射

目录：

data/sqlite/

向量索引

用于：

文档检索

语义记忆

本地知识库

目录：

data/vector/

JSONL

用于：

高吞吐审计备份

事件流记录

开发期调试

目录：

data/logs/

十、建议的 API 边界
对外公开

只暴露一个：

services/api-gateway

例如：

POST /v1/chat

POST /v1/speech/transcribe

POST /v1/tasks/plan

POST /v1/tasks/execute

GET /v1/tasks/{id}

GET /v1/audit/{task_id}

本地内部

其他服务只监听：

127.0.0.1

Unix domain socket

或内部 gRPC

这样安全边界更清楚。

十一、这个项目最合理的“启动顺序”

不是所有模块一起写。
最稳妥的顺序是：

第 1 批

agentd

api-gateway

planner-service

tool-executor

registry/

file-tools

apps/command-palette

第 2 批

asr-service

tts-service

memory-service

rag-service

status-panel

第 3 批

ocr-service

nl-shell

sdk/

infra/deb

infra/flatpak

第 4 批

vlm-service

app-connectors

更复杂的自动化工作流
