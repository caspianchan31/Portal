# Boss Console MVP TODO

## Current MVP Scope

- Connect to a live OpenClaw Gateway over WebSocket
- Read runtime snapshots from `config.get`, `status`, `health`, `system-presence`, `node.list`, `sessions.list`, and `channels.status`
- Show configured agents and runtime status in a single dashboard
- Create, edit, and delete Gateway agents through `config.patch`
- Create, edit, assign, complete, and delete local todos bound to agent ids

## Must Finish Before Calling It Done

- Verify agent delete is stable across Gateway reconnects and restarts
- Clear stale UI state after reconnect so the selected agent and registry list always match the latest `agents.list`
- Make todo state fully consistent after agent deletion, including owner dropdown refresh
- Add an explicit reconnect status for Gateway restart windows instead of showing mixed success/error signals
- Decide whether todo data should stay local-only or be persisted to Gateway-side config

## Quality Fixes

- Reduce noisy historical error messages after successful reconnects
- Keep command feed focused on useful events instead of raw high-frequency telemetry
- Add a lightweight empty-state message when `agents.list` is empty but Gateway is connected
- Tighten copy so all MVP actions map to real behavior and no placeholder action remains

## Post-MVP

- Session-to-agent mapping improvements when runtime ids and configured ids do not line up
- Rich raw inspector for selected entities
- Safer conflict handling for concurrent `config.patch` writes
- Search, filter, and sort for larger agent lists
- Gateway-backed todo persistence and multi-operator collaboration
