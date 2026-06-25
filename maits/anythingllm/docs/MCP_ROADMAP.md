# MCP Roadmap — MAIT:#AnythingLLM

> #WeOwnVer: v0.1.0 · Status: 🟡 Prototype · Scope: reference for RAG ingestion

Model Context Protocol (MCP) integration is the roadmap path for connecting
AnythingLLM threads to external tools and services. This document covers the
current state, what's possible now, and the planned trajectory.

---

## Current State

AnythingLLM supports MCP servers that run alongside the main application.
MCP server configurations are stored at:
`/app/server/storage/plugins/anythingllm_mcp_servers.json`

A management script (`mcp.sh`) is available in the K8s deployment tooling for
operators to add, modify, list, and remove MCP server configurations.

### What MCP Enables Now

- **Tool calling from agent threads** — agents in ALLM can invoke MCP-hosted
  tools during conversations
- **Plugin-based architecture** — each MCP server is an independently configured
  plugin, not hard-coded into the platform
- **FluentMCP framework** — standardized protocol for cross-platform MCP
  integration

---

## Current Integration Targets

### WordPress (via FluentMCP)

**Status:** Available — `mcp.sh` has an `add-fluentmcp` command
**Purpose:** Connect ALLM threads to WordPress content management

Enables agents to:
- Read and query WordPress posts and pages
- Search content across the WordPress site
- Integrate CMS content into RAG workflows

### Custom MCP Servers

**Status:** Available via `mcp.sh` custom server add command
**Definition:** Any externally hosted MCP-compatible server

The `mcp.sh` script supports adding custom MCP servers with:
- Server name and description
- Endpoint URL
- Authentication headers (API keys)
- Environment configuration

---

## Roadmap

### Near-term (Current W26+)

| Capability | Status | Notes |
|------------|--------|-------|
| Plugin-based tool integration | Available | Per-server configuration in JSON |
| WordPress content access | Available | Via FluentMCP |
| Custom external tool integration | Available | Via custom MCP server config |
| Multi-server orchestration | Possible | Multiple servers can be configured per instance |

### Medium-term (Post-W26)

| Capability | Notes |
|------------|-------|
| MCP-enabled MAIT tool calling | MAIT threads calling external tools via MCP |
| Data connector expansion | Additional sources beyond Paperless-ngx |
| Agent skill imports | AnythingLLM Community Hub agent skills — currently restricted to verified/private items only |

### Longer-term

The MCP roadmap is part of the broader platform evolution. As the ecosystem
matures, MCP will become the primary integration layer between MAITs and
external systems. The architecture is designed to be protocol-agnostic —
nothing done through ALLM is the exclusive path.

---

## MCP Configuration Details

### Config File Format

```json
{
  "mcpServers": [
    {
      "name": "server-name",
      "description": "What this server does",
      "type": "fluentmcp" | "custom",
      "endpoint": "https://...",
      "headers": {
        "Authorization": "Bearer ..."
      }
    }
  ]
}
```

### Management Operations (via `mcp.sh`)

| Operation | Description |
|-----------|-------------|
| Add FluentMCP | Register a FluentMCP-compatible server |
| Add custom | Register a generic MCP server with custom endpoint/auth |
| Modify | Update an existing server configuration |
| List | Show all configured MCP servers |
| Remove | Delete a server configuration |

---

## Key Principles

1. **MCP is additive, not required** — ALLM works without MCP for core RAG
   and LLM functionality
2. **Protocol agnosticism** — MCP is today's integration layer; the system
   is designed to work with whatever protocol emerges as standard
3. **Security boundaries** — MCP servers operate with their own authentication;
   MAIT access is scoped by workspace