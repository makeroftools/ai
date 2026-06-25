# RAG Pipeline — MAIT:#AnythingLLM

> #WeOwnVer: v0.1.0 · Status: 🟡 Prototype · Scope: reference for RAG ingestion

AnythingLLM's Retrieval-Augmented Generation pipeline enables agents to ground
their responses in uploaded documents. This is the primary mechanism by which MAIT
knowledge becomes available to agent threads.

---

## Ingestion Flow

```text
Document Upload
      │
      ▼
  ┌──────────────┐
  │  Workspace    │
  │  Folder       │
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐      ┌─────────────────┐
  │  Document     │─────▶│  Embedding      │
  │  Processing   │      │  Engine         │
  └──────────────┘      └────────┬────────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │   LanceDB     │
                          │  (Vector DB)  │
                          └──────────────┘
```

1. **Upload** — document added to a workspace folder
2. **Process** — document is parsed (text extraction, chunking)
3. **Embed** — chunks are vectorized by the embedding engine
4. **Store** — vectors indexed in LanceDB, associated with the workspace

When an agent asks a question, the RAG pipeline retrieves relevant chunks by
vector similarity, augments the prompt with them, and the LLM generates a
context-grounded response.

---

## Embedding Engine

### Configuration

| Setting | Default | Notes |
|---------|---------|-------|
| **Engine** | `native` | Built-in embedding — no external API needed |
| **Model** | Auto-selected | Based on AnythingLLM version |
| **Vector DB** | `lancedb` | Embedded, zero-config, no separate container |

The `native` engine runs locally in-process. No external embedding API call is
required, which means no additional latency or cost. The alternative is to use
OpenRouter as the embedding provider (`openrouter` mode), which enables model
selection but introduces external API dependency.

### Performance Characteristics

- LanceDB is an embedded columnar vector store — it lives in the container's
  filesystem and shares memory with the application
- Vector search is in-process (no network hop)
- Index quality scales with document quality, not quantity
- No index tuning required for typical workloads

---

## Folder Structure

Workspace documents are organized into a folder hierarchy. The intended layout
separates user content from system content:

| Folder | Purpose | Visibility |
|--------|---------|------------|
| `_USERS_/` | User-specific documents, identities, working notes | Per-user (by convention) |
| `_SYS_/` | System documents — rules, protocols, templates | All agents in workspace |
| `docs/` | Operational documentation, guides | All agents in workspace |

MAIT reference documents (like those in the MAIT's `docs/` directory) should be
uploaded to `_SYS_/` or `docs/` for visibility by the entire workspace.

---

## Data Connectors

AnythingLLM supports native data connectors for direct document ingestion from
external sources. The key connector in the WeOwn ecosystem:

### Paperless-ngx Connector

**Status:** Available natively in AnythingLLM
**Purpose:** Direct ingestion from Paperless-ngx document management

The Paperless-ngx connector enables:
- Automatic sync of documents from Paperless-ngx into the ALLM workspace
- Documents remain searchable via both Paperless-ngx (metadata) and ALLM (content)
- Scanned documents processed through Paperless-ngx OCR are available for RAG

### Other Connectors (by AnythingLLM)

- Web scraping (URL ingestion)
- File upload (drag-and-drop document upload)
- Code repository ingestion (roadmap)

---

## Document Types

AnythingLLM supports common document formats for RAG ingestion:
- PDF, TXT, MD (Markdown)
- CSV, JSON (structured data)
- Images with OCR (via Tesseract, when configured)

---

## Operational Notes

- **Re-embedding:** When the embedding model changes, existing documents must be
  re-embedded. The platform handles this on a per-document basis.
- **Chunk size:** Controlled by AnythingLLM settings. Smaller chunks improve
  precision; larger chunks improve recall.
- **Deletion:** Removing a document from a workspace removes its vectors at the
  next sync cycle.
- **Cross-workspace isolation:** Each workspace has its own vector store.
  Documents in one workspace are not visible to another.