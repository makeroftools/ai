# Custom Agent Skills — MAIT:#AnythingLLM

> #WeOwnVer: v0.1.0 · Status: 🟡 Prototype · Scope: reference for RAG ingestion
>
> Source: [docs.anythingllm.com](https://docs.anythingllm.com/agent/custom/introduction) (v1.15.0)
> Verified: 2026-06-25

Custom agent skills extend AnythingLLM's `@agent` with user-defined NodeJS plugins.
Anything from a simple API call to operating-system invocations — if it can be done
in NodeJS, it can be a custom skill.

**Not available in AnythingLLM Cloud.** Docker (since v1.2.2) and Desktop (since
v1.6.5) only.

---

## Architecture

### File Structure

```
plugins/agent-skills/<hubId>/
├── plugin.json    ← REQUIRED: Metadata, inputs, entrypoint
├── handler.js     ← REQUIRED: The skill's runtime logic
├── README.md      ← Recommended: description, requirements, usage
└── ...            ← Any additional NodeJS modules you bundle
```

All custom skills live under `plugins/agent-skills/` in the storage directory:
- **Docker:** `<STORAGE_LOCATION>/plugins/agent-skills/`
- **Desktop:** `<storage-dir>/plugins/agent-skills/`
- **Dev:** `server/storage/plugins/agent-skills/`

The folder name **must** match the `hubId` property in `plugin.json`.

### How Skills Are Loaded

AnythingLLM **hot-loads** custom skills — no restart needed.

- Adding a new skill: reload the page for it to appear in the UI
- Modifying during active agent session: `/exit` first
- Skills appear in the **Agent Skills** settings page (toggle on/off)

---

## plugin.json Reference

```json
{
  "active": true,
  "hubId": "open-meteo-weather-api",
  "name": "Get Weather",
  "schema": "skill-1.0.0",
  "version": "1.0.0",
  "description": "Gets the weather for a given location",
  "entrypoint": {
    "file": "handler.js",
    "params": {
      "latitude": { "description": "Latitude", "type": "string" },
      "longitude": { "description": "Longitude", "type": "string" }
    }
  },
  "imported": true
}
```

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `active` | boolean | Must be `true` |
| `hubId` | string | Unique ID — **must match parent folder name** |
| `name` | string | Human-readable name in UI |
| `schema` | string | Must be `"skill-1.0.0"` |
| `version` | string | Skill version |
| `description` | string | Short description |
| `entrypoint.file` | string | Entrypoint (typically `"handler.js"`) |
| `entrypoint.params` | object | Parameters the agent passes to handler |
| `imported` | boolean | Must be `true` |

### setup_args — Dynamic UI Configuration

Creates input fields in the AnythingLLM UI for API keys, etc. Values accessible
in `handler.js` via `this.runtimeArgs["MY_KEY"]`.

```json
"setup_args": {
  "MY_API_KEY": {
    "type": "string",
    "required": false,
    "input": {
      "type": "text",
      "default": "",
      "placeholder": "sk-...",
      "hint": "API key for the service"
    }
  }
}
```

### examples — Few-Shot Prompting

1-3 examples help the LLM invoke the skill correctly:

```json
"examples": [
  { "prompt": "Weather in Tokyo?", "call": "{\"latitude\": 35.6895, \"longitude\": 139.6917}" }
]
```

---

## handler.js Reference

### Rules

- Export `module.exports.runtime` with a `handler` function
- Handler receives params object from `entrypoint.params`
- **Must return a string** — anything else breaks the agent
- Use `await` for async, wrap in try/catch
- `require` modules inside function scope (not global)

### Runtime API

| Method | Description |
|--------|-------------|
| `this.runtimeArgs` | Setup args from plugin.json |
| `this.introspect(msg)` | Log visible to user during execution |
| `this.logger(msg)` | Console debug log |
| `this.config` | `name`, `hubId`, `version` |
| `this.requestToolApproval(opts)` | Pause for user approval before destructive action |

### requestToolApproval

```javascript
const approval = await this.requestToolApproval({
  payload: { recordId: 123 },
  description: "Delete record 123? Cannot be undone.",
});
if (!approval.approved) return approval.message;
```

Returns `{ approved, message }`. 120s timeout = rejection. Scoped to skill's `hubId`.

### Example

```javascript
module.exports.runtime = {
  handler: async function ({ latitude, longitude }) {
    try {
      this.introspect(`Fetching weather...`);
      const res = await fetch(
        `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current_weather=true`
      );
      const data = await res.json();
      return JSON.stringify({ temp: data.current_weather.temperature });
    } catch (e) {
      return `Failed: ${e.message}`;
    }
  },
};
```

---

## Availability

| Platform | Since |
|----------|-------|
| Docker | v1.2.2+ (commit `d1103e`) |
| Desktop | v1.6.5+ |
| Cloud | ❌ Not available |

---

## Security

⚠️ **Only run custom skills you trust.** They execute arbitrary NodeJS.

- Use `requestToolApproval` for destructive operations
- API keys go in `setup_args`, not hardcoded
- Test in non-production first
- Custom skills are new — may have bugs

---

## Related Docs

| Document | Link |
|----------|------|
| Introduction | `docs.anythingllm.com/agent/custom/introduction` |
| Developer Guide | `docs.anythingllm.com/agent/custom/developer-guide` |
| plugin.json Reference | `docs.anythingllm.com/agent/custom/plugin-json` |
| handler.js Reference | `docs.anythingllm.com/agent/custom/handler-js` |