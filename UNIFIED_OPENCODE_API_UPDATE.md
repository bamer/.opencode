# Unified OpenCode API (Port 4096) - Implementation Plan

## Overview
Migrate all agents, watcher, orchestrator, and CEO to use OpenCode HTTP API on port 4096 instead of CLI.

## Components to Update

### 1. Core Client Library
- **File**: `agents/opencode_client.py` ✅ DONE
- **Status**: Already updated to use port 4096
- **Features**: HTTP API with CLI fallback

### 2. Watcher System
- **File**: `src/watcher/launcher.py`
- **Current**: Uses CLI `opencode --model ... --prompt ...`
- **Update**: Use HTTP API (create session, send message, get response)
- **Reason**: Faster, more reliable, handles structured responses

### 3. Orchestrator
- **File**: `src/orchestrator/` (need to locate)
- **Update**: Replace CLI calls with HTTP API
- **Add**: Agent routing logic

### 4. Agent Profiles
- **Location**: `agents/{architect,researcher,skeptic,creative,learning-extractor}`
- **Current**: Likely using CLI
- **Update**: Use HTTP API client
- **Add**: Agent-specific prompts and orchestration

### 5. CEO Advisor (SWARN)
- **File**: `agents/dashboard_sentinel_ceo.py`
- **Current**: Uses basic AI calls (probably CLI)
- **Update**: Switch to HTTP API
- **Add**: Executive analysis via port 4096

### 6. Missing Agents to Create
Based on parties.yaml, ensure all agents exist:
- ✅ architect (exists: `agents/architect/`)
- ✅ researcher (exists: `agents/researcher/`)
- ✅ skeptic (exists: `agents/skeptic/`)
- ✅ creative (exists: `agents/creative/`)
- ✅ learning-extractor (exists: `agents/learning-extractor/`)

## Implementation Priority

### Phase 1: Foundation (Immediate)
1. Update watcher launcher to use HTTP API
2. Create unified agent base class with HTTP API support
3. Test with single agent (researcher)

### Phase 2: Agents (Next)
1. Update all agent modules to use unified base
2. Add agent-specific system prompts
3. Connect to orchestrator

### Phase 3: Orchestration (Then)
1. Create orchestrator that routes requests to agents
2. Implement party-based agent composition
3. Add routing intelligence

### Phase 4: Executive (Final)
1. Update CEO advisor to use HTTP API
2. Add strategic analysis via unified client
3. Implement CEO-specific metrics and insights

## Port 4096 Configuration

**Server startup**:
```bash
opencode serve --port 4096
```

**API Endpoints**:
- `GET /global/health` - Server health
- `GET /config/providers` - Available providers/models
- `POST /session` - Create session
- `POST /session/{id}/message` - Send prompt
- `DELETE /session/{id}` - Cleanup
- `GET /session/{id}` - Get session details

## Agent Architecture

Each agent will have:
```
agents/{agent-name}/
  __init__.py           # Agent class
  prompt.md             # System prompt
  config.yaml           # Agent config
  handlers/
    *.py                # Specific handlers
```

## Integration Points

1. **Watcher** → HTTP API → OpenCode
2. **Orchestrator** → Routes to Agents
3. **Agents** → Use unified HTTP client
4. **CEO** → Calls orchestrator for analysis
5. **Dashboard** → Gets metrics from agents

## Testing Strategy

1. `test_opencode_api.py` - Test port 4096
2. `test_agent_http.py` - Test agent via HTTP
3. `test_orchestrator_routing.py` - Test orchestrator
4. Integration tests for each party

## Files to Create/Update

```
Priority 1:
├── src/watcher/launcher.py (UPDATE)
├── agents/opencode_client.py (DONE ✅)
├── agents/base_agent.py (CREATE)

Priority 2:
├── agents/architect/agent.py (UPDATE)
├── agents/researcher/agent.py (UPDATE)
├── agents/skeptic/agent.py (UPDATE)
├── agents/creative/agent.py (UPDATE)
├── agents/learning-extractor/agent.py (UPDATE)

Priority 3:
├── src/orchestrator/orchestrator.py (CREATE/UPDATE)
├── src/orchestrator/party_router.py (CREATE)

Priority 4:
├── agents/dashboard_sentinel_ceo.py (UPDATE)
└── agents/swarn_orchestrator.py (CREATE - if separate)
```

## Success Criteria

- [ ] Port 4096 responds to all requests
- [ ] Watcher uses HTTP API
- [ ] All agents respond via HTTP
- [ ] Orchestrator routes correctly
- [ ] CEO gets AI analysis via HTTP
- [ ] No CLI fallbacks needed
- [ ] Response times < 30s
- [ ] All parties work correctly

## Next Steps

1. Update watcher launcher.py
2. Create base_agent.py with HTTP client
3. Update each agent to use new base
4. Create orchestrator with party routing
5. Update CEO advisor
6. Full integration test
