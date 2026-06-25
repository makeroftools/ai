# MCP in AnythingLLM — MAIT:#AnythingLLM

> #WeOwnVer: v0.1.0 · Status: 🟡 Prototype · Scope: reference for RAG ingestion
>
> Source: [docs.anythingllm.com](https://docs.anythingllm.com/mcp-compatibility/overview) (v1.14.2)
> Verified: 2026-06-25 — corrected from earlier inference-based draft

Model Context Protocol (MCP) is an open protocol developed by Anthropic that
enables LLM applications to connect with external tools and data sources.
AnythingLLM supports **Tools** loading via MCP Servers. Resources, Prompts, and
Sampling are **not** supported.

MCP is self-hosting only — it is not available in the AnythingLLM Cloud service.

---

## Architecture

### How MCP Servers Work in AnythingLLM

MCP Servers are external processes that expose tools the AnythingLLM agent can
call. They run alongside the main application and are managed through the
`anythingllm_mcp_servers.json` configuration file.

```text
┌────────────────────────────────────────────────────┐
│                AnythingLLM Container                │
│                                                      │
│   ┌──────────────┐     ┌────────────────────────┐   │
│   │    Agent      │────▶│   MCP Server: face-gen │   │
│   │  (LLM + RAG)  │     │   (npx process)        │   │
│   │               │     ├────────────────────────┤   │
│   │ @agent invoke │────▶│   MCP Server: youtube  │   │
│   │ triggers boot │     │   (uvx process)        │   │
│   └──────────────┘     ├────────────────────────┤   │
│                         │   MCP Server: postgres │   │
│                         │   (streamable HTTP)    │   │
│                         └────────────────────────┘   │
└────────────────────────────────────────────────────┘
```

### Supported Transport Types

| Transport | Type Value | When to Use |
|-----------|------------|-------------|
| **StdIO** | *(default)* | Local command-based MCP servers — requires `command` + `args` |
| **SSE** | `"sse"` | Server-Sent Events streaming — requires `url` |
| **Streamable** | `"streamable"` | Alternative streaming protocol — requires `url` |

If no `type` is specified, `sse` is assumed.

---

## Configuration

### File Location

The MCP Server configuration is stored at:
`<STORAGE_LOCATION>/plugins/anythingllm_mcp_servers.json`

The file is **auto-created** when you open the Agent Skills page in the AnythingLLM
UI. You do not need to create it manually.

In the Docker deployment, `STORAGE_LOCATION` is set via the `STORAGE_LOCATION`
environment variable.

### Config File Format

```json
{
  "mcpServers": {
    "face-generator": {
      "command": "npx",
      "args": ["@dasheck0/face-generator"],
      "env": {
        "MY_ENV_VAR": "my-env-var-value"
      }
    },
    "mcp-youtube": {
      "command": "uvx",
      "args": ["mcp-youtube"]
    },
    "postgres-http": {
      "type": "streamable",
      "url": "http://localhost:3003",
      "headers": {
        "X-API-KEY": "api-key"
      }
    }
  }
}
```

Each server entry is an object in the `mcpServers` dictionary. The key is the
server name. Supported fields:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `command` | For StdIO | string | The executable to run (e.g. `npx`, `uvx`, `node`) |
| `args` | No | string[] | Arguments passed to the command |
| `type` | For SSE/Streamable | string | `"sse"` or `"streamable"` |
| `url` | For SSE/Streamable | string | Endpoint URL for the MCP server |
| `headers` | No | object | Custom HTTP headers sent with requests |
| `env` | No | object | Environment variables for the MCP server process |
| `anythingllm.autoStart` | No | boolean | Set `false` to prevent automatic startup |

---

## Startup Behavior

### When MCP Servers Start

AnythingLLM **does not** start MCP servers automatically when the container/app
starts — this prevents resource overloading on boot.

MCP servers start when either of these occurs:
1. **The Agent Skills page is opened** in the AnythingLLM UI
2. **The `@agent` directive is invoked** in a chat

All MCP servers start in the background. Subsequent boots are faster because the
servers are already cached.

### Autostart Prevention

To prevent a specific MCP server from starting automatically (e.g., to save
resources), set `anythingllm.autoStart: false`:

```json
{
  "mcpServers": {
    "face-generator": {
      "command": "npx",
      "args": ["@dasheck0/face-generator"],
      "anythingllm": {
        "autoStart": false
      }
    }
  }
}
```

Servers with `autoStart: false` must be started manually from the UI.

---

## Docker-Specific Details

### Pre-installed Commands

The Docker base image (`ubuntu:jammy-20240627.1`) comes with these commands
pre-installed:
- `npx`
- `uv` / `uvx`
- `node`
- `bash`

You do not need to install these manually in the Docker deployment.

### File Persistence

MCP server libraries are cached inside the container. If the container is
stopped or deleted, the cached libraries are lost and must be re-downloaded.
This also applies to any manually installed tools (`uv tool install xyz`).

### Writing Files to the Host

MCP servers run inside the container. To write files to the host machine, use
the path prefix:
```
/app/server/storage/...
```
This maps to the `STORAGE_LOCATION` directory defined when the container was
started.

### UI Management

The AnythingLLM MCP Management UI provides:
- **Reload/Restart** — Refresh all MCP servers from config without restarting the container
- **Status view** — See which servers are running, stopped, or errored
- **Error logs** — View error output per server
- **Start/Stop** — Toggle individual servers on the fly
- **Tool listing** — View all available tools from loaded servers
- **Delete** — Remove a server from the config file and kill its process

---

## Intelligent Tool Selection

AnythingLLM includes **Intelligent Tool Selection**, which is enabled by default.
This feature ensures that only the tools relevant to the current chat are added
to the prompt window — rather than loading every configured tool on every chat.

**Benefits:**
- Saves up to 80% on token usage per chat
- Faster response times, especially for local models
- Better context management — prompt space is used for conversation, not tools

This applies to both built-in skills and MCP servers. It only activates when
more than the `Max Tools` threshold is set in Agent Skills settings.

---

## Limitations

| Limitation | Details |
|------------|---------|
| **Cloud not supported** | MCP is self-hosted Docker/Desktop only |
| **Tools only** | Resources, Prompts, and Sampling are not supported |
| **Container persistence** | Docker: cached libraries lost on container delete |
| **LLM dependency** | Not all LLMs support tool calling — small local models may not work |
| **Startup time** | More MCP servers = longer initial startup. Plan resources accordingly. |

---

## Security

⚠️ **Never run MCP servers you do not trust.** AnythingLLM does not endorse or
guarantee the security of third-party MCP tools.

Key security considerations:
- MCP servers run as processes with access to the environment variables you
  configure — treat credentials accordingly
- StdIO servers run commands from your container/host — verify what `npx`/`uvx`
  packages do before installing
- SSE/Streamable servers connect to external URLs — ensure the endpoint is
  trusted and the connection is encrypted
- Tool issues should be reported to the MCP author, not AnythingLLM maintainers

---

## Troubleshooting

### LLM Not Calling MCP Server

1. Verify the MCP server is running and the tool appears in the Agent Skills page
2. Check the model — small local models with limited context windows may not
   reliably use tools
3. Ensure the model supports tool/function calling

### MCP Server Errors

- **Docker:** Check the container logs
- **Desktop:** Check the application logs

### Manual Tool Installation

Some MCP servers require `uv tool install <package>`. For Docker:
1. Open a shell into the container
2. Run the install command
3. Click "Refresh" in the Agent Skills page

### Support Channels

- MCP Discussion board (upstream)
- AnythingLLM Discord server (community)
- **Do not open GitHub issues** for third-party MCP tool problems

---

## Comparison: Docker vs Desktop

| Aspect | Docker | Desktop |
|--------|--------|---------|
| **Commands pre-installed** | npx, uv/uvx, node, bash | Must install manually |
| **Required version** | Any current | v1.8.0+ |
| **Tool persistence** | Lost on container delete | Persists on host |
| **Host file access** | `/app/server/storage/...` only | Any host path |
| **Cloud support** | N/A (self-hosted only) | N/A (local only) |

---

## Related Docs

| Document | Link |
|----------|------|
| Agent Setup | `docs.anythingllm.com/agent/setup` |
| Agent Overview | `docs.anythingllm.com/agent/overview` |
| Intelligent Tool Selection | `docs.anythingllm.com/agent/intelligent-tool-selection` |
| MCP Specification | `modelcontextprotocol.io` (Anthropic) |
| MCP Discussion Board | Community forum for tool issues |