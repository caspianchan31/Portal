const PROTOCOL_VERSION = 3;
const STORAGE_KEY = "openclaw-boss-console";
const SESSION_STORAGE_KEY = "openclaw-boss-console-session";
const DEFAULT_URL = "";
const OPENCLAW_CONTROL_CLIENT_ID = "openclaw-control-ui";
const OPENCLAW_CONTROL_CLIENT_MODE = "webchat";
const OPENCLAW_OPERATOR_SCOPES = ["operator.admin", "operator.approvals", "operator.pairing"];

const appShell = document.querySelector("#appShell");
const heroMetrics = document.querySelector("#heroMetrics");
const agentGrid = document.querySelector("#agentGrid");
const detailName = document.querySelector("#detailName");
const detailState = document.querySelector("#detailState");
const detailRole = document.querySelector("#detailRole");
const detailBrief = document.querySelector("#detailBrief");
const detailMetrics = document.querySelector("#detailMetrics");
const taskCount = document.querySelector("#taskCount");
const taskList = document.querySelector("#taskList");
const timelineList = document.querySelector("#timelineList");
const timelineBody = document.querySelector("#timelineBody");
const commandFeedToggle = document.querySelector("#commandFeedToggle");
const workflowList = document.querySelector("#workflowList");
const currentTime = document.querySelector("#currentTime");
const detailAvatar = document.querySelector("#detailAvatar");
const connectionBadge = document.querySelector("#connectionBadge");
const connectionHint = document.querySelector("#connectionHint");
const gatewayForm = document.querySelector("#gatewayForm");
const gatewayUrlInput = document.querySelector("#gatewayUrl");
const gatewayTokenInput = document.querySelector("#gatewayToken");
const gatewayPasswordInput = document.querySelector("#gatewayPassword");
const connectButton = document.querySelector("#connectButton");
const refreshButton = document.querySelector("#refreshButton");
const disconnectButton = document.querySelector("#disconnectButton");
const refreshAgentButton = document.querySelector("#refreshAgentButton");
const stageStatusLabel = document.querySelector("#stageStatusLabel");
const stageIndicator = document.querySelector(".status-indicator");
const agentEditorForm = document.querySelector("#agentEditorForm");
const agentIdInput = document.querySelector("#agentIdInput");
const agentNameInput = document.querySelector("#agentNameInput");
const agentIdentityInput = document.querySelector("#agentIdentityInput");
const agentWorkspaceInput = document.querySelector("#agentWorkspaceInput");
const agentDirInput = document.querySelector("#agentDirInput");
const agentModelInput = document.querySelector("#agentModelInput");
const agentThemeInput = document.querySelector("#agentThemeInput");
const agentDefaultInput = document.querySelector("#agentDefaultInput");
const agentSubmitButton = document.querySelector("#agentSubmitButton");
const agentCancelButton = document.querySelector("#agentCancelButton");
const agentRegistryList = document.querySelector("#agentRegistryList");
const agentRegistryMeta = document.querySelector("#agentRegistryMeta");
const todoEditorForm = document.querySelector("#todoEditorForm");
const todoTitleInput = document.querySelector("#todoTitleInput");
const todoOwnerInput = document.querySelector("#todoOwnerInput");
const todoStatusInput = document.querySelector("#todoStatusInput");
const todoPriorityInput = document.querySelector("#todoPriorityInput");
const todoNotesInput = document.querySelector("#todoNotesInput");
const todoSubmitButton = document.querySelector("#todoSubmitButton");
const todoCancelButton = document.querySelector("#todoCancelButton");
const todoBoardList = document.querySelector("#todoBoardList");
const todoMeta = document.querySelector("#todoMeta");
const languageSwitch = document.querySelector("#languageSwitch");
const sidebarToggle = document.querySelector("#sidebarToggle");

const SUPPORTED_LANGUAGES = ["en", "zh-CN"];
const UI_COPY = {
  en: {
    sidebar_eyebrow: "Executive Command Center",
    sidebar_copy: "Turn OpenClaw Gateway runtime into a sharper cockpit for AI teams.",
    sidebar_expand: "Expand sidebar",
    sidebar_collapse: "Collapse sidebar",
    nav_overview: "Overview",
    nav_stage: "Agent Stage",
    nav_inspector: "Inspector",
    nav_workspace: "Workspace",
    language_label: "Language",
    workspace_mode_label: "Workspace Mode",
    workspace_mode_title: "AI Team Cockpit",
    workspace_mode_copy: "The left rail sets the tone. The workspace focuses on live status, agent stage, and coordination.",
    live_signals_label: "Live Signals",
    hero_eyebrow: "Control Room",
    hero_title: "Boss overview for your AI team runtime.",
    hero_copy: "Connect OpenClaw Gateway and turn sessions, nodes, presence, and channels into one stable AI team workspace.",
    connection_status_label: "Connection",
    system_time_label: "System Time",
    connect_button: "Connect Gateway",
    refresh_button: "Refresh Snapshot",
    disconnect_button: "Disconnect",
    agent_stage_title: "OpenClaw Agent Stage",
    inspector_tag: "Inspector",
    current_tasks_title: "Current Tasks",
    actions_title: "Actions",
    command_feed_title: "Command Feed",
    runtime_surfaces_title: "Runtime Surfaces",
    agent_registry_title: "OpenClaw Agent Registry",
    agent_name_label: "Display Name",
    agent_id_help: "Unique ID in multi-agent routing. Maps to dedicated session, workspace, and state storage.",
    agent_name_help: "Human-readable name for the UI and `agents.list`.",
    agent_identity_label: "SOUL.md Identity",
    agent_identity_help: "`SOUL.md` defines the identity, voice, and boundaries shown by this agent.",
    agent_workspace_help: "Workspace root. This usually hosts `AGENTS.md`, `SOUL.md`, `TOOLS.md`, `USER.md`, and `memory.md`.",
    agent_dir_help: "Per-agent state directory for auth profiles, model registry, and per-agent config.",
    agent_model_help: "Leave blank to inherit from `main`, or provide `provider/model` or model JSON.",
    agent_theme_label: "Theme (Optional)",
    agent_theme_help: "An optional product-side tag, not a required OpenClaw field.",
    agent_default_label: "Default Agent",
    agent_default_help: "Marks this agent as the default entry point.",
    todo_board_title: "Todo Board",
    todo_title_label: "Task Title",
    todo_owner_label: "Owner",
    todo_status_label: "Status",
    todo_priority_label: "Priority",
    todo_notes_label: "Notes",
    time_local: "Local",
    feed_boot_title: "Boss Console",
    feed_boot_body:
      "Waiting for OpenClaw Gateway. Once connected, the workspace will read `agents.list`, `sessions.list`, `node.list`, `system-presence`, and `channels.status`.",
    default_todo_auth_title: "Verify Gateway auth and allowed origin",
    default_todo_auth_notes: "Confirm that gateway.controlUi.allowedOrigins includes the current page origin.",
    default_todo_agent_title: "Review OpenClaw agent configuration",
    default_todo_agent_notes: "Check agents.list, workspace, agentDir, model, and default flags.",
    todo_status_todo: "To Do",
    todo_status_doing: "In Progress",
    todo_status_done: "Done",
    todo_untitled: "Todo {index}",
    inherits_main: "{model} · inherits main agent",
    just_now: "Just now",
    list_count: "{count} items",
    stage_live: "Live sync",
    stage_waiting: "Waiting",
    tls_fail:
      "TLS handshake failed. If it works in your main browser but not here, this browser instance likely does not trust the Gateway certificate.",
    no_challenge: "Socket opened, but the Gateway did not return `connect.challenge`. Check the control protocol endpoint.",
    challenge_unfinished:
      "Received `connect.challenge`, but the handshake did not finish. Check token/password and make sure gateway.controlUi.allowedOrigins includes this origin.",
    connection_closed_reason: "Connection closed: {reason}",
    ws_failed:
      "WebSocket connection failed. Common causes include an untrusted certificate, incorrect Gateway URL, auth mismatch, or current origin not being allowed.",
    standby: "Standby",
    agent_brief_sessions: "{count} live session(s) matched. workspace={workspace}",
    agent_brief_no_sessions: "Loaded from `agents.list`, but no running session has matched this agent yet.",
    tasks_todos: "Todos",
    tasks_count: "{count} items",
    default_yes: "Yes",
    default_no: "No",
    agent_latest_none: "No session is bound to this agent yet.",
    entity_session_summary: "Live session entity from `sessions.list`.",
    entity_node_summary: "Live node entity from `node.list`.",
    entity_presence_summary: "Live presence entity from `system-presence`.",
    entity_channel_summary: "Live channel entity from `channels.status`.",
    entity_session_latest: "Current state {state}",
    entity_node_latest: "Caps {caps}, updated {updated}",
    entity_channel_latest: "channel {id} is currently {state}",
    task_session_id: "Session ID",
    task_bound_agent: "Bound Agent",
    task_channel: "Channel",
    task_device_id: "Device ID",
    task_platform: "Platform",
    task_caps: "Capabilities",
    task_device: "Device",
    task_roles: "Roles",
    task_scopes: "Scopes",
    task_channel_id: "Channel ID",
    task_type: "Type",
    task_meta: "Meta",
    placeholder_name: "Waiting Slot {index}",
    placeholder_role: "Live OpenClaw agents and runtime entities will appear here after connection.",
    placeholder_state_connected: "Syncing",
    placeholder_state_disconnected: "Offline",
    placeholder_summary: "This slot has not received a live agent configuration or runtime entity yet.",
    placeholder_brief_connected:
      "Gateway is connected, but `agents.list`, `sessions.list`, `node.list`, `system-presence`, or `channels.status` has not returned yet.",
    placeholder_brief_disconnected: "Connect OpenClaw Gateway first.",
    task_reserved_slot: "Reserved Slot",
    task_config_source: "Config Source",
    reserved_slot_meta: "Automatically fills with live agent config and runtime entities after connection.",
    latest_waiting_snapshot: "Waiting for the first snapshot batch.",
    latest_not_connected: "Gateway not connected yet.",
    summary_agents_label: "OpenClaw Agents",
    summary_agents_note_connected: "from config.get / agents.list",
    summary_agents_note_waiting: "Waiting for Gateway connection",
    summary_connection_label: "Connection",
    online: "Online",
    offline: "Offline",
    summary_synced: "Latest snapshot synced",
    summary_waiting_connection: "Waiting to connect",
    summary_todo_done_label: "Todo / Done",
    workflow_gateway_agents_title: "Gateway Agents",
    workflow_todo_title: "Todo Board",
    workflow_sessions_title: "Sessions",
    workflow_nodes_title: "Nodes",
    workflow_channels_title: "Channels / Presence",
    workflow_gateway_agents_owner: "{count} configured agents",
    workflow_gateway_agents_desc: "Reads and updates `agents.list` directly with real CRUD operations.",
    connected_state: "Connected",
    waiting_config: "Waiting for config.get",
    workflow_todo_owner: "{count} todos",
    workflow_todo_desc: "Todos are bound to real OpenClaw agents and support edit, complete, and delete.",
    workflow_unfinished: "{count} unfinished",
    workflow_sessions_owner: "{count} sessions",
    workflow_sessions_desc: "Live session overview from `sessions.list`.",
    workflow_nodes_owner: "{count} nodes",
    workflow_nodes_desc: "Node capabilities and device state from `node.list`.",
    workflow_nodes_error: "Issues detected",
    workflow_nodes_ok: "Healthy",
    workflow_channels_desc: "Channel state and operator/node presence in one place.",
    synced: "Synced",
    task_count_value: "{count} tasks",
    detail_brief_assigned: "{total} todos assigned, {remaining} unfinished.",
    detail_brief_none: "No todo is assigned to this OpenClaw agent yet. Use the Todo Board below.",
    unassigned: "Unassigned",
    waiting_config_short: "Waiting for config.get",
    registry_owner: "{count} Gateway Agents",
    registry_empty_disconnected: "Connect Gateway to create, edit, or delete real OpenClaw agents.",
    registry_secondary: "secondary",
    registry_summary_empty: "This agent has not filled in SOUL.md / workspace / agentDir / model details yet.",
    action_view: "View",
    action_edit: "Edit",
    action_delete: "Delete",
    registry_empty_agents: "`agents.list` is empty. Use the form above to create the first OpenClaw agent.",
    todo_meta: "{total} todos · {done} done",
    todo_notes_empty: "No notes yet",
    action_mark_done: "Mark Done",
    action_mark_undone: "Mark Open",
    todo_empty: "No todos yet. Create one and bind it to a real OpenClaw agent.",
    gateway_not_connected: "Gateway is not connected",
    rpc_timeout: "{method} timed out",
    rpc_failed: "Gateway request failed",
    connection_handshaking: "Handshaking",
    connection_handshaking_hint: "Received connect.challenge. Sending the operator connect request.",
    reconnecting: "Reconnecting",
    reconnect_hint: "{reason}. Auto reconnecting in {seconds}s.",
    manual_disconnect: "Disconnected manually",
    reconnect_prepare: "Preparing to reconnect",
    reconnect_retry: "Reconnecting",
    connecting: "Connecting",
    connecting_hint: "Connecting to {url}",
    failed: "Failed",
    waiting_challenge: "Waiting for challenge",
    waiting_challenge_hint: "Socket is open. Waiting for the Gateway to send connect.challenge.",
    non_json_frame: "Received a non-JSON frame: {data}",
    connected_hint: "protocol {protocol} / scopes {scopes}",
    hello_ok_body: "Handshake complete. protocol={protocol}, tick={tick}ms",
    gateway_error: "Gateway returned an error",
    error: "Error",
    closed: "Closed",
    gateway_closed: "Gateway Closed",
    create_gateway_agent: "Create Gateway Agent",
    save_gateway_agent: "Save Gateway Agent",
    create_todo: "Create Todo",
    save_todo: "Save Todo",
    cancel: "Cancel",
    model_json_error: "If the Model field contains JSON, it must be valid JSON.",
    agent_id_required: "Agent ID is required.",
    config_change_submitted: "Submitted agents.list change: {action} {id}",
    applying_config: "Applying Config",
    applying_config_hint: "config.patch submitted. Waiting for the Gateway to sync agent changes.",
    cannot_update_agent: "Gateway is not connected, so a real agent cannot be created or updated.",
    submit_agent_failed: "Failed to submit agent: {error}",
    todo_updated: "Todo updated: {title}",
    todo_created: "Todo created: {title}",
    agent_deleted: "Deleted OpenClaw agent: {name}",
    delete_agent_failed: "Failed to delete agent: {error}",
    cannot_delete_agent: "Gateway is not connected, so a real agent cannot be deleted.",
    refresh_snapshot_blocked: "Gateway is not connected, so snapshots cannot be refreshed.",
    expand: "Expand",
    collapse: "Collapse",
    todo_toggled: "{title} was marked {state}",
    todo_state_done: "done",
    todo_state_open: "open",
    todo_deleted: "Todo deleted: {title}",
    refresh_entities_blocked: "Gateway is not connected, so entities cannot be refreshed.",
    origin_hint: "Current page origin is {origin}. Add it to gateway.controlUi.allowedOrigins before connecting to a remote Gateway.",
    socket_opened: "Socket opened: {url}",
    socket_closed_code: "socket closed ({code})",
  },
  "zh-CN": {
    sidebar_eyebrow: "指挥中枢",
    sidebar_copy: "将 OpenClaw Gateway 的运行态整理成更清晰的 AI 团队驾驶舱。",
    sidebar_expand: "展开侧边栏",
    sidebar_collapse: "收起侧边栏",
    nav_overview: "总览",
    nav_stage: "Agent 舞台",
    nav_inspector: "检视席",
    nav_workspace: "工作台",
    language_label: "语言",
    workspace_mode_label: "工作模式",
    workspace_mode_title: "AI 团队驾驶舱",
    workspace_mode_copy: "左侧负责导航和氛围，右侧工作区专注实时状态、Agent 舞台与协作动作。",
    live_signals_label: "实时信号",
    hero_eyebrow: "控制室",
    hero_title: "你的 AI 团队运行总览。",
    hero_copy: "连接 OpenClaw Gateway，把会话、节点、presence 和 channel 收拢到一个稳定的 AI 团队工作区。",
    connection_status_label: "连接状态",
    system_time_label: "系统时间",
    connect_button: "连接 Gateway",
    refresh_button: "刷新快照",
    disconnect_button: "断开连接",
    agent_stage_title: "OpenClaw Agent 指挥舞台",
    inspector_tag: "汇报席",
    current_tasks_title: "当前任务",
    actions_title: "操作",
    command_feed_title: "指令与汇报流",
    runtime_surfaces_title: "系统面概览",
    agent_registry_title: "OpenClaw Agent 管理",
    agent_name_label: "配置名称",
    agent_id_help: "多 agent 路由中的唯一标识；会映射到独立会话、工作区和状态目录。",
    agent_name_help: "展示名；用于 UI 和 `agents.list` 里的可读名称。",
    agent_identity_label: "SOUL.md 人设名",
    agent_identity_help: "`SOUL.md` 定义身份、语气和边界；这里填写你希望该 agent 对外呈现的人设名。",
    agent_workspace_help: "工作区根目录。这里通常放 `AGENTS.md`、`SOUL.md`、`TOOLS.md`、`USER.md` 和 `memory.md`。",
    agent_dir_help: "每个 agent 独立的状态目录，保存 auth profiles、model registry 和 per-agent config。",
    agent_model_help: "留空则继承 `main` agent；也可填写 `provider/model` 或 model JSON。",
    agent_theme_label: "Theme（可选）",
    agent_theme_help: "这是当前产品里的附加标签，不属于 OpenClaw 官方必需字段。",
    agent_default_label: "默认 Agent",
    agent_default_help: "勾选后会把这个 agent 标记为默认入口。",
    todo_board_title: "待办事项管理",
    todo_title_label: "任务标题",
    todo_owner_label: "负责人",
    todo_status_label: "状态",
    todo_priority_label: "优先级",
    todo_notes_label: "备注",
    time_local: "本地",
    feed_boot_title: "Boss Console",
    feed_boot_body: "等待接入 OpenClaw Gateway。连接后会读取 `agents.list`、`sessions.list`、`node.list`、`system-presence` 和 `channels.status`。",
    default_todo_auth_title: "核对 Gateway 授权与 Origin",
    default_todo_auth_notes: "确认 gateway.controlUi.allowedOrigins 已包含当前页面 Origin。",
    default_todo_agent_title: "审查 OpenClaw agent 配置",
    default_todo_agent_notes: "核对 agents.list、workspace、agentDir、model 和 default 标志。",
    todo_status_todo: "待开始",
    todo_status_doing: "进行中",
    todo_status_done: "已完成",
    todo_untitled: "待办 {index}",
    inherits_main: "{model} · 继承 main agent",
    just_now: "刚刚",
    list_count: "{count} 项",
    stage_live: "实时同步中",
    stage_waiting: "等待连接",
    tls_fail: "TLS 握手失败。若你在本机浏览器可连、这里不可连，通常是当前浏览器实例不信任该 Gateway 证书。",
    no_challenge: "Socket 已打开，但 Gateway 没有返回 `connect.challenge`。请检查控制协议端点。",
    challenge_unfinished: "已收到 `connect.challenge`，但握手未完成。请检查 token/password，以及 gateway.controlUi.allowedOrigins 是否包含当前 origin。",
    connection_closed_reason: "连接已关闭：{reason}",
    ws_failed: "WebSocket 连接失败。常见原因包括证书不受信任、Gateway 地址错误、认证不匹配，或当前 origin 未被 Gateway 放行。",
    standby: "待命",
    agent_brief_sessions: "已匹配 {count} 个真实 session。workspace={workspace}",
    agent_brief_no_sessions: "已从 `agents.list` 读取配置，但目前还没有匹配到运行中的 session。",
    tasks_todos: "待办",
    tasks_count: "{count} 项",
    default_yes: "是",
    default_no: "否",
    agent_latest_none: "当前尚无 session 绑定到这个 agent。",
    entity_session_summary: "真实 session 实体，来自 `sessions.list`。",
    entity_node_summary: "真实 node 实体，来自 `node.list`。",
    entity_presence_summary: "真实 presence 实体，来自 `system-presence`。",
    entity_channel_summary: "真实 channel 实体，来自 `channels.status`。",
    entity_session_latest: "当前状态 {state}",
    entity_node_latest: "能力 {caps}，最近更新 {updated}",
    entity_channel_latest: "channel {id} 当前 {state}",
    task_session_id: "Session 标识",
    task_bound_agent: "绑定 Agent",
    task_channel: "所属 Channel",
    task_device_id: "设备标识",
    task_platform: "平台",
    task_caps: "能力摘要",
    task_device: "设备",
    task_roles: "角色",
    task_scopes: "权限域",
    task_channel_id: "Channel 标识",
    task_type: "类型",
    task_meta: "Meta",
    placeholder_name: "等待 Agent {index}",
    placeholder_role: "连接后自动映射真实 OpenClaw agent 和 runtime 实体",
    placeholder_state_connected: "等待快照",
    placeholder_state_disconnected: "未连接",
    placeholder_summary: "当前卡位还没有接收到真实 agent 配置或运行态实体。",
    placeholder_brief_connected: "Gateway 已连接，但还没有收到 `agents.list`、`sessions.list`、`node.list`、`system-presence` 或 `channels.status`。",
    placeholder_brief_disconnected: "请先连接 OpenClaw Gateway。",
    task_reserved_slot: "预留槽位",
    task_config_source: "配置来源",
    reserved_slot_meta: "连接成功后会自动填充真实 agent 配置和运行态",
    latest_waiting_snapshot: "等待第一批快照返回。",
    latest_not_connected: "尚未连接 Gateway。",
    summary_agents_label: "OpenClaw Agents",
    summary_agents_note_connected: "来自 config.get / agents.list",
    summary_agents_note_waiting: "等待 Gateway 连接",
    summary_connection_label: "连接状态",
    online: "在线",
    offline: "离线",
    summary_synced: "已同步最新快照",
    summary_waiting_connection: "等待建立连接",
    summary_todo_done_label: "待办 / 已完成",
    workflow_gateway_agents_title: "Gateway Agents",
    workflow_todo_title: "Todo Board",
    workflow_sessions_title: "Sessions",
    workflow_nodes_title: "Nodes",
    workflow_channels_title: "Channels / Presence",
    workflow_gateway_agents_owner: "{count} 个配置 agent",
    workflow_gateway_agents_desc: "直接读取和维护 `agents.list`，支持真实的增删改查。",
    connected_state: "已接通",
    waiting_config: "等待 config.get",
    workflow_todo_owner: "{count} 项待办",
    workflow_todo_desc: "待办绑定真实 OpenClaw agent，支持编辑、完成和删除。",
    workflow_unfinished: "{count} 项未完成",
    workflow_sessions_owner: "{count} 个会话",
    workflow_sessions_desc: "来自 `sessions.list` 的真实会话总览。",
    workflow_nodes_owner: "{count} 个节点",
    workflow_nodes_desc: "来自 `node.list` 的节点能力与设备情况。",
    workflow_nodes_error: "存在异常",
    workflow_nodes_ok: "正常",
    workflow_channels_desc: "channel 状态和 operator / node presence 汇总。",
    synced: "已同步",
    task_count_value: "{count} 项",
    detail_brief_assigned: "当前绑定 {total} 项待办，未完成 {remaining} 项。",
    detail_brief_none: "这个 OpenClaw agent 还没有绑定待办，可以从下方 Todo Board 分配。",
    unassigned: "未指派",
    waiting_config_short: "等待 config.get",
    registry_owner: "{count} 个 Gateway Agent",
    registry_empty_disconnected: "先连接 Gateway，才能对真实 OpenClaw agent 执行增删改查。",
    registry_secondary: "secondary",
    registry_summary_empty: "当前 agent 还没有补充 SOUL.md / workspace / agentDir / model 信息。",
    action_view: "查看",
    action_edit: "编辑",
    action_delete: "删除",
    registry_empty_agents: "`agents.list` 为空。直接用上方表单创建第一个 OpenClaw agent。",
    todo_meta: "{total} 项待办 · {done} 项已完成",
    todo_notes_empty: "暂无备注",
    action_mark_done: "标记完成",
    action_mark_undone: "改回未完成",
    todo_empty: "还没有待办，先新增一项任务并绑定给真实 OpenClaw agent。",
    gateway_not_connected: "Gateway 未连接",
    rpc_timeout: "{method} 超时",
    rpc_failed: "Gateway 请求失败",
    connection_handshaking: "握手中",
    connection_handshaking_hint: "已收到 connect.challenge，正在发送 operator connect 请求。",
    reconnecting: "重连中",
    reconnect_hint: "{reason}，{seconds}s 后自动重连。",
    manual_disconnect: "手动断开",
    reconnect_prepare: "准备重连",
    reconnect_retry: "重连中",
    connecting: "连接中",
    connecting_hint: "正在连接 {url}",
    failed: "失败",
    waiting_challenge: "等待 challenge",
    waiting_challenge_hint: "Socket 已打开，等待 Gateway 发送 connect.challenge。",
    non_json_frame: "收到非 JSON 帧: {data}",
    connected_hint: "protocol {protocol} / scopes {scopes}",
    hello_ok_body: "握手成功，protocol={protocol}，tick={tick}ms",
    gateway_error: "Gateway 返回错误",
    error: "错误",
    closed: "已关闭",
    gateway_closed: "Gateway Closed",
    create_gateway_agent: "新增 Gateway Agent",
    save_gateway_agent: "保存 Gateway Agent",
    create_todo: "新增待办",
    save_todo: "保存待办",
    cancel: "取消编辑",
    model_json_error: "Model 字段如果填写 JSON，必须是合法 JSON。",
    agent_id_required: "Agent ID 不能为空。",
    config_change_submitted: "已提交 agents.list 变更：{action} {id}",
    applying_config: "应用配置中",
    applying_config_hint: "已调用 config.patch 提交 agent 变更，正在等待 Gateway 同步。",
    cannot_update_agent: "未连接 Gateway，无法创建或更新真实 agent。",
    submit_agent_failed: "提交 agent 失败: {error}",
    todo_updated: "已更新待办：{title}",
    todo_created: "已新增待办：{title}",
    agent_deleted: "已删除 OpenClaw agent：{name}",
    delete_agent_failed: "删除 agent 失败: {error}",
    cannot_delete_agent: "未连接 Gateway，无法删除真实 agent。",
    refresh_snapshot_blocked: "当前未连接 Gateway，无法刷新快照。",
    expand: "展开",
    collapse: "收起",
    todo_toggled: "{title} 已{state}",
    todo_state_done: "标记完成",
    todo_state_open: "改回未完成",
    todo_deleted: "已删除待办：{title}",
    refresh_entities_blocked: "未连接 Gateway，无法刷新实体。",
    origin_hint: "当前页面 Origin 是 {origin}。若连接远端 Gateway，请先把它加入 gateway.controlUi.allowedOrigins。",
    socket_opened: "Socket 已打开: {url}",
    socket_closed_code: "socket 关闭 ({code})",
  },
};

function detectLanguage() {
  const params = new URLSearchParams(window.location.search);
  const fromQuery = params.get("lang");
  if (SUPPORTED_LANGUAGES.includes(fromQuery)) return fromQuery;
  const stored = JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}")?.language;
  if (SUPPORTED_LANGUAGES.includes(stored)) return stored;
  return (navigator.language || "").toLowerCase().startsWith("zh") ? "zh-CN" : "en";
}

const INITIAL_LANGUAGE = detectLanguage();
let activeLanguage = INITIAL_LANGUAGE;

function interpolate(template, values = {}) {
  return String(template).replace(/\{(\w+)\}/g, (_, key) => String(values[key] ?? `{${key}}`));
}

function t(key, values) {
  const lang = activeLanguage || "en";
  const table = UI_COPY[lang] || UI_COPY.en;
  const fallback = UI_COPY.en[key] || key;
  return interpolate(table[key] || fallback, values);
}

const runtime = {
  ws: null,
  connected: false,
  selectedAgentId: "slot-0",
  rpcCounter: 0,
  pending: new Map(),
  tickIntervalMs: 15000,
  lastError: "",
  agentDraftId: null,
  todoDraftId: null,
  reconnectEnabled: false,
  reconnectUrl: "",
  reconnectTimer: null,
  reconnectAttempt: 0,
  language: INITIAL_LANGUAGE,
  socketOpened: false,
  challengeReceived: false,
  snapshot: {
    hello: null,
    status: null,
    health: null,
    presence: [],
    nodes: [],
    sessions: [],
    channels: [],
    toolsCatalog: null,
  },
  gatewayConfig: {
    hash: "",
    raw: null,
    defaults: {},
    agents: [],
    loaded: false,
  },
  todos: [],
  feed: [
    {
      title: t("feed_boot_title"),
      time: t("time_local"),
      body: t("feed_boot_body"),
    },
  ],
};

const placeholderPalette = [
  { tint: "rgba(123, 234, 255, 0.5)", tintStrong: "#5bd6ff", badgeColor: "#8be9ff" },
  { tint: "rgba(255, 198, 109, 0.48)", tintStrong: "#f6b14b", badgeColor: "#f5bf6d" },
  { tint: "rgba(103, 240, 180, 0.48)", tintStrong: "#43d796", badgeColor: "#67f0b4" },
  { tint: "rgba(255, 124, 124, 0.54)", tintStrong: "#ff7171", badgeColor: "#ff7c7c" },
  { tint: "rgba(159, 146, 255, 0.44)", tintStrong: "#8d7fff", badgeColor: "#9f92ff" },
  { tint: "rgba(255, 155, 106, 0.54)", tintStrong: "#ff8b4f", badgeColor: "#ff9b6a" },
];

const defaultTodos = [
  {
    id: "todo-launch-control-room",
    title: t("default_todo_auth_title"),
    ownerId: "",
    status: "doing",
    priority: "P1",
    notes: t("default_todo_auth_notes"),
  },
  {
    id: "todo-agent-audit",
    title: t("default_todo_agent_title"),
    ownerId: "",
    status: "todo",
    priority: "P2",
    notes: t("default_todo_agent_notes"),
  },
];

function applyLanguage() {
  document.documentElement.lang = runtime.language;
  document.querySelectorAll("[data-i18n]").forEach((node) => {
    node.textContent = t(node.dataset.i18n);
  });
  agentIdInput.placeholder = runtime.language === "zh-CN" ? "例如：approval-alpha" : "e.g. approval-alpha";
  agentNameInput.placeholder = runtime.language === "zh-CN" ? "例如：Approval Alpha" : "e.g. Approval Alpha";
  agentIdentityInput.placeholder = runtime.language === "zh-CN" ? "例如：审批官 Alpha" : "e.g. Approval Lead";
  agentWorkspaceInput.placeholder = runtime.language === "zh-CN" ? "例如：~/.openclaw/workspace" : "e.g. ~/.openclaw/workspace";
  agentDirInput.placeholder =
    runtime.language === "zh-CN" ? "例如：~/.openclaw/agents/approval-alpha/agent" : "e.g. ~/.openclaw/agents/approval-alpha/agent";
  agentModelInput.placeholder =
    runtime.language === "zh-CN" ? "留空则继承 main agent；或填写 gpt-5-mini / JSON" : "inherit main agent, or enter gpt-5-mini / JSON";
  agentThemeInput.placeholder = runtime.language === "zh-CN" ? "例如：finance-ops" : "e.g. finance-ops";
  todoTitleInput.placeholder = runtime.language === "zh-CN" ? "例如：整理审批清单" : "e.g. Review approval queue";
  todoNotesInput.placeholder =
    runtime.language === "zh-CN" ? "补充执行说明、依赖项或交付物。" : "Execution notes, dependencies, or deliverables.";
  connectButton.textContent = t("connect_button");
  refreshButton.textContent = t("refresh_button");
  disconnectButton.textContent = t("disconnect_button");
  refreshAgentButton.textContent = t("refresh_button");
  agentCancelButton.textContent = t("cancel");
  todoCancelButton.textContent = t("cancel");
  commandFeedToggle.textContent = timelineBody.classList.contains("is-collapsed") ? t("expand") : t("collapse");
  todoStatusInput.querySelector('option[value="todo"]').textContent = t("todo_status_todo");
  todoStatusInput.querySelector('option[value="doing"]').textContent = t("todo_status_doing");
  todoStatusInput.querySelector('option[value="done"]').textContent = t("todo_status_done");
  languageSwitch?.querySelectorAll("[data-lang]").forEach((button) => {
    button.classList.toggle("is-active", button.dataset.lang === runtime.language);
  });
  if (sidebarToggle) {
    const collapsed = appShell?.classList.contains("sidebar-collapsed");
    sidebarToggle.setAttribute("aria-label", collapsed ? t("sidebar_expand") : t("sidebar_collapse"));
    sidebarToggle.setAttribute("aria-expanded", String(!collapsed));
  }
}

function setLanguage(nextLanguage) {
  if (!SUPPORTED_LANGUAGES.includes(nextLanguage) || nextLanguage === runtime.language) return;
  runtime.language = nextLanguage;
  activeLanguage = nextLanguage;
  saveConfig();
  applyLanguage();
  if (!runtime.connected) {
    const hint = t("origin_hint", { origin: window.location.origin });
    setConnectionState(t("offline"), hint);
  }
  renderAll();
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function generateId(prefix) {
  if (crypto.randomUUID) return `${prefix}-${crypto.randomUUID()}`;
  return `${prefix}-${Date.now()}-${Math.random().toString(16).slice(2, 8)}`;
}

function formatPriority(priority) {
  return priority || "P2";
}

function formatTodoStatus(status) {
  if (status === "doing") return t("todo_status_doing");
  if (status === "done") return t("todo_status_done");
  return t("todo_status_todo");
}

function getTodoStatusClass(status) {
  if (status === "done") return "status-good";
  if (status === "doing") return "status-warn";
  return "status-danger";
}

function normalizeTodo(raw, index) {
  return {
    id: raw.id || generateId(`todo-${index}`),
    title: (raw.title || t("todo_untitled", { index: index + 1 })).trim(),
    ownerId: raw.ownerId || "",
    status: raw.status || "todo",
    priority: formatPriority(raw.priority),
    notes: (raw.notes || "").trim(),
  };
}

function normalizeModelValue(model) {
  if (!model) return "";
  if (typeof model === "string") return model.trim();
  if (typeof model === "object") return JSON.stringify(model);
  return String(model);
}

function deriveAgentDisplayName(raw, index) {
  return (raw.identity?.name || raw.name || raw.id || `Agent ${index + 1}`).trim();
}

function normalizeGatewayAgent(raw, index) {
  return {
    id: (raw.id || raw.name || `agent-${index + 1}`).trim(),
    name: (raw.name || raw.id || `Agent ${index + 1}`).trim(),
    identityName: (raw.identity?.name || raw.name || raw.id || `Agent ${index + 1}`).trim(),
    workspace: (raw.workspace || "").trim(),
    agentDir: (raw.agentDir || "").trim(),
    model: normalizeModelValue(raw.model),
    theme: (raw.identity?.theme || "").trim(),
    default: Boolean(raw.default),
    summary: [
      raw.workspace ? `workspace ${raw.workspace}` : null,
      raw.agentDir ? `agentDir ${raw.agentDir}` : null,
      raw.model ? `model ${normalizeModelValue(raw.model)}` : null,
    ]
      .filter(Boolean)
      .join(" · "),
    raw,
  };
}

function getMainAgentModel(excludeAgentId = "") {
  const mainAgent = runtime.gatewayConfig.agents.find((agent) => agent.id === "main" && agent.id !== excludeAgentId && agent.model);
  if (mainAgent) return mainAgent.model;
  return normalizeModelValue(runtime.gatewayConfig.defaults?.model);
}

function getAgentModelLabel(agent) {
  if (agent.model) return agent.model;
  const inheritedModel = getMainAgentModel(agent.id);
  return inheritedModel ? t("inherits_main", { model: inheritedModel }) : "---";
}

function loadConfig() {
  try {
    const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
    return {
      gatewayUrl: parsed.gatewayUrl || "",
      language: SUPPORTED_LANGUAGES.includes(parsed.language) ? parsed.language : null,
      todos: Array.isArray(parsed.todos) ? parsed.todos : defaultTodos,
    };
  } catch {
    return {
      gatewayUrl: "",
      language: null,
      todos: defaultTodos,
    };
  }
}

function saveConfig() {
  localStorage.setItem(
    STORAGE_KEY,
    JSON.stringify({
      gatewayUrl: normalizeGatewayUrl(gatewayUrlInput.value),
      language: runtime.language,
      todos: runtime.todos,
    }),
  );
}

function loadSessionConnection() {
  try {
    const parsed = JSON.parse(sessionStorage.getItem(SESSION_STORAGE_KEY) || "{}");
    return {
      gatewayUrl: parsed.gatewayUrl || "",
      token: parsed.token || "",
      password: parsed.password || "",
      autoReconnect: parsed.autoReconnect !== false,
    };
  } catch {
    return {
      gatewayUrl: "",
      token: "",
      password: "",
      autoReconnect: false,
    };
  }
}

function saveSessionConnection() {
  sessionStorage.setItem(
    SESSION_STORAGE_KEY,
    JSON.stringify({
      gatewayUrl: normalizeGatewayUrl(gatewayUrlInput.value),
      token: gatewayTokenInput.value,
      password: gatewayPasswordInput.value,
      autoReconnect: true,
    }),
  );
}

function clearSessionConnection() {
  sessionStorage.removeItem(SESSION_STORAGE_KEY);
}

function normalizeGatewayUrl(rawValue) {
  const value = (rawValue || "").trim();
  if (!value) return DEFAULT_URL;
  if (!value.startsWith("ws://")) return value;

  try {
    const url = new URL(value);
    if (url.hostname !== "127.0.0.1" && url.hostname !== "localhost") {
      url.protocol = "wss:";
      return url.toString().replace(/\/$/, "");
    }
  } catch {
    return value;
  }

  return value;
}

function formatTimestamp(value) {
  if (!value) return t("just_now");
  const date = typeof value === "number" ? new Date(value) : new Date(String(value));
  if (Number.isNaN(date.getTime())) return String(value);
  return new Intl.DateTimeFormat(runtime.language, {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  }).format(date);
}

function summarizeValue(value) {
  if (value == null) return "---";
  if (typeof value === "string" || typeof value === "number" || typeof value === "boolean") return String(value);
  if (Array.isArray(value)) return t("list_count", { count: value.length });
  return JSON.stringify(value).slice(0, 140);
}

function cloneValue(value) {
  if (typeof structuredClone === "function") return structuredClone(value);
  return JSON.parse(JSON.stringify(value));
}

function countRoles(entries) {
  return entries.reduce((sum, entry) => sum + (Array.isArray(entry.roles) ? entry.roles.length : 0), 0);
}

function normalizeList(payload) {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.items)) return payload.items;
  if (Array.isArray(payload?.entries)) return payload.entries;
  if (Array.isArray(payload?.nodes)) return payload.nodes;
  if (Array.isArray(payload?.sessions)) return payload.sessions;
  if (Array.isArray(payload?.channels)) return payload.channels;
  if (Array.isArray(payload?.list)) return payload.list;
  return [];
}

function upsertFeed(entry) {
  runtime.feed.unshift(entry);
  runtime.feed = runtime.feed.slice(0, 14);
}

function setConnectionState(label, hint, isOnline = false) {
  connectionBadge.textContent = label;
  connectionHint.textContent = hint;
  stageStatusLabel.textContent = isOnline ? t("stage_live") : t("stage_waiting");
  stageIndicator.classList.toggle("live", isOnline);
  stageIndicator.classList.toggle("offline", !isOnline);
}

function deriveGatewayFailureHint(closeReason = "") {
  const normalizedUrl = normalizeGatewayUrl(gatewayUrlInput.value.trim());
  const usingSecureWs = normalizedUrl.startsWith("wss://");
  const reasonText = String(closeReason || "").trim();

  if (usingSecureWs && !runtime.socketOpened) {
    return t("tls_fail");
  }

  if (runtime.socketOpened && !runtime.challengeReceived) {
    return t("no_challenge");
  }

  if (runtime.challengeReceived && !runtime.connected) {
    return t("challenge_unfinished");
  }

  if (reasonText) {
    return t("connection_closed_reason", { reason: reasonText });
  }

  return t("ws_failed");
}

function deriveStatusClass(state) {
  if (!state) return "status-warn";
  const text = String(state).toLowerCase();
  if (
    text.includes("error") ||
    text.includes("异常") ||
    text.includes("fail") ||
    text.includes("closed") ||
    text.includes("blocked") ||
    text.includes("offline")
  ) {
    return "status-danger";
  }
  if (
    text.includes("warn") ||
    text.includes("pending") ||
    text.includes("degraded") ||
    text.includes("idle") ||
    text.includes("high")
  ) {
    return "status-warn";
  }
  return "status-good";
}

function deriveBadgeColor(statusClass) {
  if (statusClass === "status-danger") return "#ff7c7c";
  if (statusClass === "status-warn") return "#f5bf6d";
  return "#67f0b4";
}

function extractConfigRoot(payload) {
  if (!payload) return {};
  return payload.config || payload.parsed || payload.value || payload.data || payload;
}

function updateGatewayConfig(payload) {
  const configRoot = extractConfigRoot(payload);
  const agentsRoot = configRoot?.agents || {};
  const agentList = normalizeList(agentsRoot.list || agentsRoot.entries || []);

  runtime.gatewayConfig = {
    hash: payload?.hash || payload?.baseHash || payload?.configHash || "",
    raw: configRoot,
    defaults: agentsRoot.defaults || {},
    agents: agentList.map((item, index) => normalizeGatewayAgent(item, index)),
    loaded: true,
  };

  runtime.todos = runtime.todos.map((todo) =>
    todo.ownerId && !runtime.gatewayConfig.agents.some((agent) => agent.id === todo.ownerId) ? { ...todo, ownerId: "" } : todo,
  );
}

function getConfiguredAgents() {
  return runtime.gatewayConfig.agents;
}

function getAgentById(id) {
  return buildAgentEntities().find((agent) => agent.id === id) || null;
}

function getConfiguredAgentById(id) {
  return runtime.gatewayConfig.agents.find((agent) => agent.id === id) || null;
}

function getTodosForAgent(agentId) {
  return runtime.todos.filter((todo) => todo.ownerId === agentId);
}

function getSessionsForAgent(agentId) {
  return runtime.snapshot.sessions.filter((session) => {
    const sessionAgent = String(session.agentId || session.agent || session.name || "").trim();
    return sessionAgent === agentId;
  });
}

function createRuntimeEntity(raw, type, index) {
  const palette = placeholderPalette[index % placeholderPalette.length];
  const state =
    raw.state || raw.status || raw.platform || (type === "presence" ? (raw.roles || []).join(", ") : "") || t("standby");
  const statusClass = deriveStatusClass(state);
  const metrics = buildMetrics(raw, type);
  const tasks = buildTasks(raw, type);
  const title = getEntityTitle(raw, type, index);
  const role = getEntityRole(raw, type);

  return {
    id: `${type}-${raw.id || raw.deviceId || raw.name || index}`,
    type,
    name: title,
    role,
    state,
    badge: getEntityBadge(type),
    badgeColor: deriveBadgeColor(statusClass),
    stateClass: statusClass,
    tint: palette.tint,
    tintStrong: palette.tintStrong,
    summary: buildSummary(raw, type),
    brief: buildBrief(raw, type),
    tasks,
    metrics,
    latest: buildLatest(raw, type),
    raw,
  };
}

function createGatewayAgentEntity(agent, index) {
  const palette = placeholderPalette[index % placeholderPalette.length];
  const sessions = getSessionsForAgent(agent.id);
  const todos = getTodosForAgent(agent.id);
  const primarySession = sessions[0] || null;
  const state = primarySession?.state || primarySession?.status || (runtime.connected ? "configured" : "offline");
  const statusClass = deriveStatusClass(state);
  const modelLabel = getAgentModelLabel(agent);
  const workspaceLabel = agent.workspace || runtime.gatewayConfig.defaults?.workspace || "---";

  return {
    id: agent.id,
    type: "gatewayAgent",
    name: deriveAgentDisplayName(agent.raw, index),
    role: agent.name === agent.id ? `Agent / ${agent.id}` : `${agent.name} / ${agent.id}`,
    state,
    badge: agent.default ? "Default" : "Agent",
    badgeColor: deriveBadgeColor(statusClass),
    stateClass: statusClass,
    tint: palette.tint,
    tintStrong: palette.tintStrong,
    summary: [
      agent.identityName ? `SOUL.md=${agent.identityName}` : null,
      agent.theme ? `theme=${agent.theme}` : null,
    ]
      .filter(Boolean)
      .join(" · "),
    brief: sessions.length
      ? t("agent_brief_sessions", { count: sessions.length, workspace: workspaceLabel })
      : t("agent_brief_no_sessions"),
    tasks: [
      { title: "Agent ID", meta: `<code>${escapeHtml(agent.id)}</code>` },
      { title: "Workspace", meta: escapeHtml(workspaceLabel) },
      { title: "Agent Dir", meta: escapeHtml(agent.agentDir || "---") },
      { title: "Model", meta: escapeHtml(modelLabel) },
      { title: t("tasks_todos"), meta: escapeHtml(t("tasks_count", { count: todos.length })) },
    ],
    metrics: {
      leftLabel: "Sessions",
      leftValue: String(sessions.length),
      midLabel: t("tasks_todos"),
      midValue: String(todos.length),
      rightLabel: "Default",
      rightValue: agent.default ? t("default_yes") : t("default_no"),
    },
    latest: primarySession
      ? `session ${primarySession.id || "---"} · channel ${primarySession.channel || "---"}`
      : agent.summary || t("agent_latest_none"),
    raw: agent.raw,
  };
}

function getEntityTitle(raw, type, index) {
  if (type === "session") return raw.title || raw.id || raw.agentId || `Session ${index + 1}`;
  if (type === "node") return raw.name || raw.id || raw.deviceId || `Node ${index + 1}`;
  if (type === "presence") return raw.label || raw.deviceId || `Presence ${index + 1}`;
  return raw.id || raw.name || `Channel ${index + 1}`;
}

function getEntityRole(raw, type) {
  if (type === "session") return `Session / ${raw.agentId || raw.agent || raw.channel || "unknown"}`;
  if (type === "node") return `Node / ${raw.platform || "runtime"}`;
  if (type === "presence") return `Presence / ${(raw.roles || []).join(", ") || "operator"}`;
  return `Channel / ${raw.kind || raw.type || "channel"}`;
}

function getEntityBadge(type) {
  if (type === "session") return "Session";
  if (type === "node") return "Node";
  if (type === "presence") return "Presence";
  return "Channel";
}

function buildSummary(raw, type) {
  if (type === "session") return t("entity_session_summary");
  if (type === "node") return t("entity_node_summary");
  if (type === "presence") return t("entity_presence_summary");
  return t("entity_channel_summary");
}

function buildBrief(raw, type) {
  if (type === "session") return `session=${raw.id || "---"}，agent=${raw.agentId || raw.agent || "---"}，channel=${raw.channel || "---"}`;
  if (type === "node") return `device=${raw.deviceId || "---"}，caps=${(raw.caps || []).length}，commands=${(raw.commands || []).length}`;
  if (type === "presence") return `device=${raw.deviceId || "---"}，scopes=${(raw.scopes || []).slice(0, 3).join(", ") || "none"}`;
  return `kind=${raw.kind || raw.type || "---"}，status=${raw.state || raw.status || "---"}`;
}

function buildLatest(raw, type) {
  if (type === "session") return raw.summary || raw.lastMessage || t("entity_session_latest", { state: raw.state || raw.status || "unknown" });
  if (type === "node") return t("entity_node_latest", { caps: (raw.caps || []).slice(0, 2).join(", ") || "none", updated: summarizeValue(raw.updatedAt || raw.lastSeenAt || "---") });
  if (type === "presence") return `roles ${(raw.roles || []).join(", ") || "none"}，transport ${raw.transport || "ws"}`;
  return t("entity_channel_latest", { id: raw.id || raw.name || "---", state: raw.state || raw.status || "unknown" });
}

function buildMetrics(raw, type) {
  if (type === "session") {
    return {
      leftLabel: "Session",
      leftValue: raw.id || "---",
      midLabel: "Agent",
      midValue: raw.agentId || raw.agent || "---",
      rightLabel: "Channel",
      rightValue: raw.channel || "---",
    };
  }

  if (type === "node") {
    return {
      leftLabel: "Caps",
      leftValue: String((raw.caps || []).length),
      midLabel: "Commands",
      midValue: String((raw.commands || []).length),
      rightLabel: "Health",
      rightValue: raw.health?.ok === false ? "Bad" : "OK",
    };
  }

  if (type === "presence") {
    return {
      leftLabel: "Roles",
      leftValue: String((raw.roles || []).length),
      midLabel: "Scopes",
      midValue: String((raw.scopes || []).length),
      rightLabel: "State",
      rightValue: raw.stateVersion || "---",
    };
  }

  return {
    leftLabel: "Kind",
    leftValue: raw.kind || raw.type || "---",
    midLabel: "Status",
    midValue: raw.state || raw.status || "---",
    rightLabel: "Meta",
    rightValue: raw.meta ? "Yes" : "No",
  };
}

function buildTasks(raw, type) {
  if (type === "session") {
    return [
      { title: t("task_session_id"), meta: `<code>${escapeHtml(raw.id || "---")}</code>` },
      { title: t("task_bound_agent"), meta: escapeHtml(raw.agentId || raw.agent || "---") },
      { title: t("task_channel"), meta: escapeHtml(raw.channel || "---") },
    ];
  }

  if (type === "node") {
    return [
      { title: t("task_device_id"), meta: `<code>${escapeHtml(raw.deviceId || raw.id || "---")}</code>` },
      { title: t("task_platform"), meta: escapeHtml(raw.platform || raw.state || "---") },
      { title: t("task_caps"), meta: escapeHtml((raw.caps || []).slice(0, 4).join(", ") || "none") },
    ];
  }

  if (type === "presence") {
    return [
      { title: t("task_device"), meta: `<code>${escapeHtml(raw.deviceId || "---")}</code>` },
      { title: t("task_roles"), meta: escapeHtml((raw.roles || []).join(", ") || "none") },
      { title: t("task_scopes"), meta: escapeHtml((raw.scopes || []).slice(0, 4).join(", ") || "none") },
    ];
  }

  return [
    { title: t("task_channel_id"), meta: `<code>${escapeHtml(raw.id || raw.name || "---")}</code>` },
    { title: t("task_type"), meta: escapeHtml(raw.kind || raw.type || "---") },
    { title: t("task_meta"), meta: escapeHtml(summarizeValue(raw.meta || raw.address || "---")) },
  ];
}

function buildAgentEntities() {
  const configuredAgents = runtime.gatewayConfig.agents.map((item, index) => createGatewayAgentEntity(item, index));
  if (configuredAgents.length) return configuredAgents;

  return Array.from({ length: 6 }, (_, index) => {
    const palette = placeholderPalette[index];
    return {
      id: `slot-${index}`,
      type: "placeholder",
      name: t("placeholder_name", { index: index + 1 }),
      role: t("placeholder_role"),
      state: runtime.connected ? t("placeholder_state_connected") : t("placeholder_state_disconnected"),
      badge: "Standby",
      badgeColor: palette.badgeColor,
      stateClass: "status-warn",
      tint: palette.tint,
      tintStrong: palette.tintStrong,
      summary: t("placeholder_summary"),
      brief: runtime.connected
        ? t("placeholder_brief_connected")
        : t("placeholder_brief_disconnected"),
      tasks: [
        { title: t("task_reserved_slot"), meta: t("reserved_slot_meta") },
        { title: t("task_config_source"), meta: "agents.list + sessions.list + node.list + system-presence" },
      ],
      metrics: {
        leftLabel: "Agents",
        leftValue: "0",
        midLabel: "Sessions",
        midValue: "0",
        rightLabel: "State",
        rightValue: runtime.connected ? "syncing" : "offline",
      },
      latest: runtime.connected ? t("latest_waiting_snapshot") : t("latest_not_connected"),
      raw: null,
    };
  });
}

function getSelectedAgent(agents) {
  return agents.find((agent) => agent.id === runtime.selectedAgentId) || agents[0];
}

function buildSummaryCards(agents) {
  const liveAgents = agents.filter((item) => item.type !== "placeholder");
  const riskCount = liveAgents.filter((item) => item.stateClass === "status-danger").length;
  const pendingCount = liveAgents.filter((item) => item.stateClass === "status-warn").length;

  return [
    {
      label: t("summary_agents_label"),
      value: String(runtime.gatewayConfig.agents.length).padStart(2, "0"),
      note: runtime.connected ? t("summary_agents_note_connected") : t("summary_agents_note_waiting"),
    },
    {
      label: t("summary_connection_label"),
      value: runtime.connected ? t("online") : t("offline"),
      note: runtime.lastError ? runtime.lastError : runtime.connected ? t("summary_synced") : t("summary_waiting_connection"),
    },
    {
      label: "Sessions / Nodes",
      value: `${runtime.snapshot.sessions.length} / ${runtime.snapshot.nodes.length}`,
      note: `presence ${runtime.snapshot.presence.length} / channels ${runtime.snapshot.channels.length}`,
    },
    {
      label: t("summary_todo_done_label"),
      value: `${runtime.todos.length} / ${runtime.todos.filter((todo) => todo.status === "done").length}`,
      note: `roles ${countRoles(runtime.snapshot.presence)}`,
    },
  ];
}

function buildWorkflows() {
  return [
    {
      title: t("workflow_gateway_agents_title"),
      owner: t("workflow_gateway_agents_owner", { count: runtime.gatewayConfig.agents.length }),
      progress: Math.min(100, runtime.gatewayConfig.agents.length * 18),
      desc: t("workflow_gateway_agents_desc"),
      state: runtime.gatewayConfig.loaded ? t("connected_state") : t("waiting_config"),
    },
    {
      title: t("workflow_todo_title"),
      owner: t("workflow_todo_owner", { count: runtime.todos.length }),
      progress: runtime.todos.length
        ? Math.round((runtime.todos.filter((todo) => todo.status === "done").length / runtime.todos.length) * 100)
        : 0,
      desc: t("workflow_todo_desc"),
      state: t("workflow_unfinished", { count: runtime.todos.filter((todo) => todo.status !== "done").length }),
    },
    {
      title: t("workflow_sessions_title"),
      owner: t("workflow_sessions_owner", { count: runtime.snapshot.sessions.length }),
      progress: Math.min(100, runtime.snapshot.sessions.length * 14),
      desc: t("workflow_sessions_desc"),
      state: summarizeValue(runtime.snapshot.status?.state || "waiting"),
    },
    {
      title: t("workflow_nodes_title"),
      owner: t("workflow_nodes_owner", { count: runtime.snapshot.nodes.length }),
      progress: Math.min(100, runtime.snapshot.nodes.length * 18),
      desc: t("workflow_nodes_desc"),
      state: runtime.snapshot.nodes.some((node) => node.health?.ok === false) ? t("workflow_nodes_error") : t("workflow_nodes_ok"),
    },
    {
      title: t("workflow_channels_title"),
      owner: `${runtime.snapshot.channels.length} / ${runtime.snapshot.presence.length}`,
      progress: Math.min(100, (runtime.snapshot.channels.length + runtime.snapshot.presence.length) * 10),
      desc: t("workflow_channels_desc"),
      state: runtime.connected ? t("synced") : t("stage_waiting"),
    },
  ];
}

function renderSummary(agents) {
  heroMetrics.innerHTML = buildSummaryCards(agents)
    .map(
      (item) => `
        <article class="summary-card">
          <span class="label">${escapeHtml(item.label)}</span>
          <strong>${escapeHtml(item.value)}</strong>
          <span>${escapeHtml(item.note)}</span>
        </article>
      `,
    )
    .join("");
}

function renderAgents(agents) {
  agentGrid.dataset.count = String(agents.length);
  agentGrid.innerHTML = agents
    .map((agent) => {
      const isActive = agent.id === runtime.selectedAgentId;
      const rigClass = agent.stateClass === "status-danger" ? "alert" : agent.stateClass === "status-warn" ? "attention" : "";
      return `
        <button
          class="agent-card ${isActive ? "active" : ""}"
          data-agent-id="${escapeHtml(agent.id)}"
          style="--agent-tint:${agent.tint}; --agent-tint-strong:${agent.tintStrong}; --badge-color:${agent.badgeColor};"
        >
          <div class="agent-top">
            <div>
              <strong class="agent-name">${escapeHtml(agent.name)}</strong>
              <div class="agent-role">${escapeHtml(agent.role)}</div>
            </div>
            <span class="agent-state ${escapeHtml(agent.stateClass)}">${escapeHtml(agent.state)}</span>
          </div>

          <div class="live2d-stage" aria-hidden="true">
            <div class="live2d-rig ${rigClass}">
              <div class="rig-aura"></div>
              <div class="rig-face"></div>
              <div class="rig-body"></div>
              <div class="rig-badge">${escapeHtml(agent.badge)}</div>
            </div>
          </div>

          <div class="agent-meta">
            <div class="metric-tile">
              <span>${escapeHtml(agent.metrics.leftLabel)}</span>
              <strong>${escapeHtml(agent.metrics.leftValue)}</strong>
            </div>
            <div class="metric-tile">
              <span>${escapeHtml(agent.metrics.midLabel)}</span>
              <strong>${escapeHtml(agent.metrics.midValue)}</strong>
            </div>
            <div class="metric-tile">
              <span>${escapeHtml(agent.metrics.rightLabel)}</span>
              <strong>${escapeHtml(agent.metrics.rightValue)}</strong>
            </div>
          </div>

          <p class="agent-brief">${escapeHtml(agent.latest)}</p>
        </button>
      `;
    })
    .join("");
}

function renderDetail(agent) {
  const assignedTodos = getTodosForAgent(agent.id);
  detailName.textContent = agent.name;
  detailState.textContent = agent.state;
  detailState.className = `detail-state ${agent.stateClass}`;
  detailRole.textContent = agent.summary;
  detailBrief.textContent = agent.brief;
  detailAvatar.style.setProperty("--detail-tint", agent.tint);
  detailAvatar.style.setProperty("--detail-tint-strong", agent.tintStrong);

  detailMetrics.innerHTML = [
    { label: agent.metrics.leftLabel, value: agent.metrics.leftValue },
    { label: agent.metrics.midLabel, value: agent.metrics.midValue },
    { label: agent.metrics.rightLabel, value: agent.metrics.rightValue },
  ]
    .map(
      (item) => `
        <article class="metric-tile">
          <span>${escapeHtml(item.label)}</span>
          <strong>${escapeHtml(item.value)}</strong>
        </article>
      `,
    )
    .join("");

  taskCount.textContent = t("task_count_value", { count: agent.tasks.length });
  taskList.innerHTML = agent.tasks
    .map(
      (task) => `
        <li>
          <strong>${escapeHtml(task.title)}</strong>
          <small>${task.meta}</small>
        </li>
      `,
    )
    .join("");

  if (agent.type === "gatewayAgent") {
    detailBrief.textContent = assignedTodos.length
      ? t("detail_brief_assigned", { total: assignedTodos.length, remaining: assignedTodos.filter((todo) => todo.status !== "done").length })
      : t("detail_brief_none");
  }
}

function renderTimeline() {
  timelineList.innerHTML = runtime.feed
    .map(
      (item) => `
        <article class="timeline-item">
          <header>
            <strong>${escapeHtml(item.title)}</strong>
            <span class="timeline-time">${escapeHtml(item.time)}</span>
          </header>
          <p>${escapeHtml(item.body)}</p>
        </article>
      `,
    )
    .join("");
}

function renderWorkflows() {
  workflowList.innerHTML = buildWorkflows()
    .map(
      (item) => `
        <article class="workflow-card">
          <header>
            <strong>${escapeHtml(item.title)}</strong>
            <span class="workflow-meta">${escapeHtml(item.owner)} · ${escapeHtml(item.state)}</span>
          </header>
          <p>${escapeHtml(item.desc)}</p>
          <div class="workflow-bar"><div style="width:${item.progress}%"></div></div>
        </article>
      `,
    )
    .join("");
}

function renderTodoOwnerOptions() {
  const currentValue = todoOwnerInput.value;
  const options = [`<option value="">${escapeHtml(t("unassigned"))}</option>`];

  getConfiguredAgents().forEach((agent) => {
    options.push(`<option value="${escapeHtml(agent.id)}">${escapeHtml(agent.identityName)} · ${escapeHtml(agent.id)}</option>`);
  });

  todoOwnerInput.innerHTML = options.join("");
  if (getConfiguredAgents().some((agent) => agent.id === currentValue)) {
    todoOwnerInput.value = currentValue;
  } else if (runtime.todoDraftId) {
    const draft = runtime.todos.find((todo) => todo.id === runtime.todoDraftId);
    todoOwnerInput.value = draft?.ownerId || "";
  } else {
    todoOwnerInput.value = "";
  }
}

function renderAgentRegistry() {
  agentRegistryMeta.textContent = runtime.gatewayConfig.loaded
    ? t("registry_owner", { count: runtime.gatewayConfig.agents.length })
    : t("waiting_config_short");

  if (!runtime.connected) {
    agentRegistryList.innerHTML = `<article class="empty-state">${escapeHtml(t("registry_empty_disconnected"))}</article>`;
    return;
  }

  agentRegistryList.innerHTML = runtime.gatewayConfig.agents.length
    ? runtime.gatewayConfig.agents
        .map((agent) => {
          const todos = getTodosForAgent(agent.id);
          const sessions = getSessionsForAgent(agent.id);
          const modelLabel = getAgentModelLabel(agent);
          return `
            <article class="registry-card">
              <div class="registry-copy">
                <div>
                  <strong>${escapeHtml(agent.identityName)}</strong>
                  <p>${escapeHtml(agent.id)} · ${escapeHtml(modelLabel)} · ${agent.default ? "default" : t("registry_secondary")}</p>
                </div>
                <span class="workflow-meta">${sessions.length} sessions / ${todos.length} todos</span>
              </div>
              <p>${escapeHtml(agent.summary || t("registry_summary_empty"))}</p>
              <div class="registry-actions">
                <button class="action-button" type="button" data-agent-action="view" data-agent-record-id="${escapeHtml(agent.id)}">${escapeHtml(t("action_view"))}</button>
                <button class="action-button" type="button" data-agent-action="edit" data-agent-record-id="${escapeHtml(agent.id)}">${escapeHtml(t("action_edit"))}</button>
                <button class="action-button" type="button" data-agent-action="delete" data-agent-record-id="${escapeHtml(agent.id)}">${escapeHtml(t("action_delete"))}</button>
              </div>
            </article>
          `;
        })
        .join("")
    : `<article class="empty-state">${escapeHtml(t("registry_empty_agents"))}</article>`;
}

function renderTodoBoard() {
  todoMeta.textContent = t("todo_meta", { total: runtime.todos.length, done: runtime.todos.filter((todo) => todo.status === "done").length });
  const selectedAgent = getAgentById(runtime.selectedAgentId);
  const items = runtime.todos.slice().sort((left, right) => {
    const priorityRank = { P1: 0, P2: 1, P3: 2 };
    return priorityRank[left.priority] - priorityRank[right.priority];
  });

  todoBoardList.innerHTML = items.length
    ? items
        .map((todo) => {
          const owner = todo.ownerId ? getConfiguredAgentById(todo.ownerId) : null;
          const isFocused = selectedAgent && todo.ownerId && todo.ownerId === selectedAgent.id;
          return `
            <article class="todo-card ${isFocused ? "focused" : ""}">
              <div class="todo-top">
                <div>
                  <strong>${escapeHtml(todo.title)}</strong>
                  <p>${escapeHtml(owner?.identityName || t("unassigned"))} · ${escapeHtml(todo.priority)}</p>
                </div>
                <span class="agent-state ${getTodoStatusClass(todo.status)}">${escapeHtml(formatTodoStatus(todo.status))}</span>
              </div>
              <p class="todo-notes">${escapeHtml(todo.notes || t("todo_notes_empty"))}</p>
              <div class="registry-actions">
                <button class="action-button" type="button" data-todo-action="toggle" data-todo-id="${escapeHtml(todo.id)}">${escapeHtml(todo.status === "done" ? t("action_mark_undone") : t("action_mark_done"))}</button>
                <button class="action-button" type="button" data-todo-action="edit" data-todo-id="${escapeHtml(todo.id)}">${escapeHtml(t("action_edit"))}</button>
                <button class="action-button" type="button" data-todo-action="delete" data-todo-id="${escapeHtml(todo.id)}">${escapeHtml(t("action_delete"))}</button>
              </div>
            </article>
          `;
        })
        .join("")
    : `<article class="empty-state">${escapeHtml(t("todo_empty"))}</article>`;
}

function renderAll() {
  const agents = buildAgentEntities();
  if (!agents.find((item) => item.id === runtime.selectedAgentId)) {
    runtime.selectedAgentId = agents[0].id;
  }

  renderSummary(agents);
  renderAgents(agents);
  renderDetail(getSelectedAgent(agents));
  renderTimeline();
  renderWorkflows();
  renderTodoOwnerOptions();
  renderAgentRegistry();
  renderTodoBoard();
}

function rpc(method, params = {}) {
  if (!runtime.ws || runtime.ws.readyState !== WebSocket.OPEN) {
    return Promise.reject(new Error(t("gateway_not_connected")));
  }

  const id = `req_${Date.now()}_${++runtime.rpcCounter}`;
  runtime.ws.send(JSON.stringify({ type: "req", id, method, params }));

  return new Promise((resolve, reject) => {
    const timeout = window.setTimeout(() => {
      runtime.pending.delete(id);
      reject(new Error(t("rpc_timeout", { method })));
    }, 7000);

    runtime.pending.set(id, { resolve, reject, timeout });
  });
}

function settlePending(message) {
  const pending = runtime.pending.get(message.id);
  if (!pending) return false;

  window.clearTimeout(pending.timeout);
  runtime.pending.delete(message.id);

  if (message.ok) {
    pending.resolve(message.payload);
  } else {
    pending.reject(new Error(message.error?.message || message.error?.details?.code || t("rpc_failed")));
  }

  return true;
}

function buildConnectParams() {
  const token = gatewayTokenInput.value.trim();
  const password = gatewayPasswordInput.value.trim();

  const params = {
    minProtocol: PROTOCOL_VERSION,
    maxProtocol: PROTOCOL_VERSION,
    client: {
      id: OPENCLAW_CONTROL_CLIENT_ID,
      version: "boss-console",
      platform: navigator.platform || "web",
      mode: OPENCLAW_CONTROL_CLIENT_MODE,
      instanceId: crypto.randomUUID ? crypto.randomUUID() : `dashboard-${Date.now()}`,
    },
    role: "operator",
    scopes: OPENCLAW_OPERATOR_SCOPES,
    caps: ["tool-events"],
    commands: [],
    permissions: {},
    locale: navigator.language || "zh-CN",
    userAgent: navigator.userAgent,
  };

  if (token || password) {
    params.auth = {};
    if (token) params.auth.token = token;
    if (password) params.auth.password = password;
  }

  return params;
}

async function fetchSnapshot() {
  const calls = [
    ["config.get", "gatewayConfig"],
    ["status", "status"],
    ["health", "health"],
    ["system-presence", "presence"],
    ["node.list", "nodes"],
    ["sessions.list", "sessions"],
    ["channels.status", "channels"],
    ["tools.catalog", "toolsCatalog"],
  ];

  const results = await Promise.allSettled(calls.map(([method]) => rpc(method)));
  results.forEach((result, index) => {
    const [method, key] = calls[index];
    if (result.status === "fulfilled") {
      if (key === "gatewayConfig") {
        updateGatewayConfig(result.value);
        return;
      }

      runtime.snapshot[key] =
        key === "presence" || key === "nodes" || key === "sessions" || key === "channels"
          ? normalizeList(result.value)
          : result.value;
      return;
    }

    runtime.lastError = result.reason.message;
    upsertFeed({
      title: "RPC",
      time: formatTimestamp(Date.now()),
      body: `${method} failed: ${result.reason.message}`,
    });
  });

  renderAll();
}

function handleGatewayEvent(message) {
  const payload = message.payload || {};
  if (message.event === "connect.challenge") {
    runtime.challengeReceived = true;
    const connectId = `connect_${Date.now()}`;
    runtime.ws.send(JSON.stringify({ type: "req", id: connectId, method: "connect", params: buildConnectParams() }));
    setConnectionState(t("connection_handshaking"), t("connection_handshaking_hint"));
    return;
  }

  if (message.event === "tick") return;

  if (message.event === "health" || message.event === "heartbeat") {
    runtime.snapshot.health = payload;
    return;
  }

  upsertFeed({
    title: message.event,
    time: formatTimestamp(payload.ts || Date.now()),
    body: summarizeValue(payload.summary || payload.message || payload),
  });

  if (["presence", "agent", "chat", "config.changed"].includes(message.event)) {
    fetchSnapshot().catch((error) => {
      runtime.lastError = error.message;
      renderAll();
    });
  } else {
    renderAll();
  }
}

function resetRuntimeState() {
  runtime.connected = false;
  runtime.lastError = "";
  runtime.socketOpened = false;
  runtime.challengeReceived = false;
  runtime.snapshot = {
    hello: null,
    status: null,
    health: null,
    presence: [],
    nodes: [],
    sessions: [],
    channels: [],
    toolsCatalog: null,
  };
  runtime.gatewayConfig = {
    hash: "",
    raw: null,
    defaults: {},
    agents: [],
    loaded: false,
  };
}

function clearReconnectTimer() {
  if (runtime.reconnectTimer) {
    window.clearTimeout(runtime.reconnectTimer);
    runtime.reconnectTimer = null;
  }
}

function scheduleReconnect(reason) {
  if (!runtime.reconnectEnabled || runtime.reconnectTimer || !runtime.reconnectUrl) return;
  runtime.reconnectAttempt += 1;
  const delay = Math.min(6000, 1200 * runtime.reconnectAttempt);
  setConnectionState(t("reconnecting"), t("reconnect_hint", { reason, seconds: Math.round(delay / 100) / 10 }));
  runtime.reconnectTimer = window.setTimeout(() => {
    runtime.reconnectTimer = null;
    openGatewayConnection({ save: false, reconnect: true });
  }, delay);
}

function disconnectGateway(reason = t("manual_disconnect"), options = {}) {
  const manual = options.manual !== false;
  clearReconnectTimer();
  if (manual) {
    runtime.reconnectEnabled = false;
    runtime.reconnectUrl = "";
    runtime.reconnectAttempt = 0;
    clearSessionConnection();
  }

  if (runtime.ws) {
    runtime.ws.onopen = null;
    runtime.ws.onmessage = null;
    runtime.ws.onerror = null;
    runtime.ws.onclose = null;
    runtime.ws.close();
    runtime.ws = null;
  }

  runtime.pending.forEach((pending) => {
    window.clearTimeout(pending.timeout);
    pending.reject(new Error(reason));
  });
  runtime.pending.clear();
  resetRuntimeState();
  setConnectionState(t("offline"), reason);
  upsertFeed({ title: t("feed_boot_title"), time: formatTimestamp(Date.now()), body: reason });
  renderAll();
}

function connectGateway(event) {
  event?.preventDefault();
  openGatewayConnection({ save: true, reconnect: false });
}

function openGatewayConnection(options = {}) {
  const save = options.save !== false;
  const reconnect = Boolean(options.reconnect);
  if (save) {
    saveConfig();
    saveSessionConnection();
  }

  if (runtime.ws || runtime.connected) {
    disconnectGateway(reconnect ? t("reconnect_prepare") : t("reconnect_retry"), { manual: false });
  }

  const url = gatewayUrlInput.value.trim() || DEFAULT_URL;
  const normalizedUrl = normalizeGatewayUrl(url);
  gatewayUrlInput.value = normalizedUrl;
  runtime.reconnectEnabled = true;
  runtime.reconnectUrl = normalizedUrl;
  setConnectionState(reconnect ? t("reconnecting") : t("connecting"), t("connecting_hint", { url: normalizedUrl || "(empty url)" }));

  try {
    runtime.ws = new WebSocket(normalizedUrl);
  } catch (error) {
    runtime.lastError = error.message;
    setConnectionState(t("failed"), error.message);
    renderAll();
    return;
  }

  runtime.ws.onopen = () => {
    runtime.socketOpened = true;
    clearReconnectTimer();
    upsertFeed({ title: "Gateway", time: formatTimestamp(Date.now()), body: t("socket_opened", { url: normalizedUrl }) });
    setConnectionState(t("waiting_challenge"), t("waiting_challenge_hint"));
    renderAll();
  };

  runtime.ws.onmessage = async (eventMessage) => {
    let message;
    try {
      message = JSON.parse(eventMessage.data);
    } catch {
      upsertFeed({ title: "Gateway", time: formatTimestamp(Date.now()), body: t("non_json_frame", { data: String(eventMessage.data).slice(0, 120) }) });
      renderAll();
      return;
    }

    if (message.type === "event") {
      handleGatewayEvent(message);
      return;
    }

    if (message.type === "res") {
      if (message.payload?.type === "hello-ok") {
        runtime.connected = true;
        runtime.reconnectAttempt = 0;
        runtime.snapshot.hello = message.payload;
        runtime.tickIntervalMs = message.payload.policy?.tickIntervalMs || runtime.tickIntervalMs;
        setConnectionState(
          t("online"),
          t("connected_hint", { protocol: message.payload.protocol, scopes: (message.payload.auth?.scopes || ["operator.read"]).join(", ") }),
          true,
        );
        upsertFeed({
          title: "hello-ok",
          time: formatTimestamp(Date.now()),
          body: t("hello_ok_body", { protocol: message.payload.protocol, tick: runtime.tickIntervalMs }),
        });
        renderAll();
        fetchSnapshot().catch((error) => {
          runtime.lastError = error.message;
          renderAll();
        });
      }

      if (!settlePending(message) && !message.ok) {
        const errorText = message.error?.message || message.error?.details?.code || t("gateway_error");
        runtime.lastError = errorText;
        setConnectionState(t("failed"), errorText);
        upsertFeed({ title: "Gateway Error", time: formatTimestamp(Date.now()), body: errorText });
        renderAll();
      }
    }
  };

  runtime.ws.onerror = () => {
    runtime.lastError = deriveGatewayFailureHint();
    setConnectionState(t("error"), runtime.lastError);
    renderAll();
  };

  runtime.ws.onclose = (closeEvent) => {
    runtime.connected = false;
    runtime.ws = null;
    const reason = closeEvent.reason || t("socket_closed_code", { code: closeEvent.code });
    const hint = deriveGatewayFailureHint(reason);
    runtime.lastError = hint;
    setConnectionState(t("closed"), hint);
    upsertFeed({ title: t("gateway_closed"), time: formatTimestamp(Date.now()), body: hint });
    renderAll();
    scheduleReconnect(reason);
  };
}

function renderClock() {
  currentTime.textContent = new Intl.DateTimeFormat(runtime.language, {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  }).format(new Date());
}

function resetAgentEditor() {
  runtime.agentDraftId = null;
  agentEditorForm.reset();
  agentDefaultInput.checked = false;
  agentSubmitButton.textContent = t("create_gateway_agent");
}

function resetTodoEditor() {
  runtime.todoDraftId = null;
  todoEditorForm.reset();
  todoStatusInput.value = "todo";
  todoPriorityInput.value = "P1";
  todoSubmitButton.textContent = t("create_todo");
  renderTodoOwnerOptions();
}

function parseModelInput(value) {
  const text = value.trim();
  if (!text) return undefined;
  if (!text.startsWith("{") && !text.startsWith("[")) return text;

  try {
    return JSON.parse(text);
  } catch {
    throw new Error(t("model_json_error"));
  }
}

function buildAgentPayloadFromForm(existingRaw = null) {
  const agentId = agentIdInput.value.trim();
  if (!agentId) throw new Error(t("agent_id_required"));

  const payload = {
    ...(existingRaw ? cloneValue(existingRaw) : {}),
    id: agentId,
    name: agentNameInput.value.trim() || agentId,
    default: agentDefaultInput.checked,
  };

  const workspace = agentWorkspaceInput.value.trim();
  const agentDir = agentDirInput.value.trim();
  const model = parseModelInput(agentModelInput.value);
  const identityName = agentIdentityInput.value.trim();
  const theme = agentThemeInput.value.trim();

  if (workspace) payload.workspace = workspace;
  else delete payload.workspace;

  if (agentDir) payload.agentDir = agentDir;
  else delete payload.agentDir;

  if (typeof model !== "undefined") payload.model = model;
  else delete payload.model;

  if (identityName || theme) {
    payload.identity = { ...(payload.identity || {}) };
    if (identityName) payload.identity.name = identityName;
    else delete payload.identity.name;

    if (theme) payload.identity.theme = theme;
    else delete payload.identity.theme;
  } else {
    delete payload.identity;
  }

  return payload;
}

async function ensureConfigHash() {
  if (runtime.gatewayConfig.hash) return runtime.gatewayConfig.hash;
  const latestConfig = await rpc("config.get");
  updateGatewayConfig(latestConfig);
  return runtime.gatewayConfig.hash;
}

function buildConfigNote(action, agentId) {
  return `boss-console:${action}:${agentId}`;
}

async function applyAgentListUpdate(nextList, action, agentId) {
  const baseHash = await ensureConfigHash();
  await rpc("config.patch", {
    raw: JSON.stringify({ agents: { list: nextList } }, null, 2),
    baseHash,
    note: buildConfigNote(action, agentId),
    restartDelayMs: 1000,
  });

  runtime.gatewayConfig.agents = nextList.map((item, index) => normalizeGatewayAgent(item, index));
  runtime.gatewayConfig.hash = "";
  upsertFeed({
    title: "Gateway Config",
    time: formatTimestamp(Date.now()),
    body: t("config_change_submitted", { action, id: agentId }),
  });
  setConnectionState(t("applying_config"), t("applying_config_hint"), true);
  renderAll();

  window.setTimeout(() => {
    if (!runtime.connected) return;
    fetchSnapshot().catch((error) => {
      runtime.lastError = error.message;
      renderAll();
    });
  }, 1600);
}

async function handleAgentSubmit(event) {
  event.preventDefault();

  if (!runtime.connected) {
    upsertFeed({ title: "Gateway Config", time: formatTimestamp(Date.now()), body: t("cannot_update_agent") });
    renderAll();
    return;
  }

  try {
    let nextList = runtime.gatewayConfig.agents.map((agent) => cloneValue(agent.raw));
    const draftId = agentIdInput.value.trim();
    const existingIndex = nextList.findIndex((item) => item.id === draftId);
    const payload = buildAgentPayloadFromForm(existingIndex >= 0 ? nextList[existingIndex] : null);
    const action = existingIndex >= 0 ? "update" : "create";

    if (payload.default) {
      nextList = nextList.map((item) => ({ ...item, default: false }));
    }

    if (existingIndex >= 0) {
      nextList.splice(existingIndex, 1, payload);
    } else {
      nextList.unshift(payload);
    }

    await applyAgentListUpdate(nextList, action, payload.id);
    runtime.selectedAgentId = payload.id;
    resetAgentEditor();
  } catch (error) {
    runtime.lastError = error.message;
    upsertFeed({ title: "Gateway Config", time: formatTimestamp(Date.now()), body: t("submit_agent_failed", { error: error.message }) });
  }

  renderAll();
}

function handleTodoSubmit(event) {
  event.preventDefault();

  const payload = normalizeTodo(
    {
      id: runtime.todoDraftId || generateId("todo"),
      title: todoTitleInput.value,
      ownerId: todoOwnerInput.value,
      status: todoStatusInput.value,
      priority: todoPriorityInput.value,
      notes: todoNotesInput.value,
    },
    runtime.todos.length,
  );

  if (runtime.todoDraftId) {
    runtime.todos = runtime.todos.map((todo) => (todo.id === runtime.todoDraftId ? payload : todo));
    upsertFeed({ title: "Todo Board", time: formatTimestamp(Date.now()), body: t("todo_updated", { title: payload.title }) });
  } else {
    runtime.todos.unshift(payload);
    upsertFeed({ title: "Todo Board", time: formatTimestamp(Date.now()), body: t("todo_created", { title: payload.title }) });
  }

  saveConfig();
  resetTodoEditor();
  renderAll();
}

function beginEditAgent(agentId) {
  const agent = runtime.gatewayConfig.agents.find((item) => item.id === agentId);
  if (!agent) return;
  runtime.agentDraftId = agent.id;
  agentIdInput.value = agent.id;
  agentNameInput.value = agent.name;
  agentIdentityInput.value = agent.identityName;
  agentWorkspaceInput.value = agent.workspace;
  agentDirInput.value = agent.agentDir;
  agentModelInput.value = agent.model;
  agentThemeInput.value = agent.theme;
  agentDefaultInput.checked = agent.default;
  agentSubmitButton.textContent = t("save_gateway_agent");
}

function beginEditTodo(todoId) {
  const todo = runtime.todos.find((item) => item.id === todoId);
  if (!todo) return;
  runtime.todoDraftId = todo.id;
  todoTitleInput.value = todo.title;
  todoOwnerInput.value = todo.ownerId || "";
  todoStatusInput.value = todo.status;
  todoPriorityInput.value = todo.priority;
  todoNotesInput.value = todo.notes;
  todoSubmitButton.textContent = t("save_todo");
}

async function deleteGatewayAgent(agentId) {
  if (!runtime.connected) {
    upsertFeed({ title: "Gateway Config", time: formatTimestamp(Date.now()), body: t("cannot_delete_agent") });
    renderAll();
    return;
  }

  const target = runtime.gatewayConfig.agents.find((item) => item.id === agentId);
  if (!target) return;

  const nextList = runtime.gatewayConfig.agents
    .filter((item) => item.id !== agentId)
    .map((item) => cloneValue(item.raw));

  try {
    await applyAgentListUpdate(nextList, "delete", agentId);
    runtime.todos = runtime.todos.map((todo) => (todo.ownerId === agentId ? { ...todo, ownerId: "" } : todo));
    saveConfig();
    if (runtime.selectedAgentId === agentId) {
      runtime.selectedAgentId = buildAgentEntities()[0]?.id || "slot-0";
    }
    if (runtime.agentDraftId === agentId) resetAgentEditor();
    upsertFeed({ title: "Gateway Config", time: formatTimestamp(Date.now()), body: t("agent_deleted", { name: target.identityName }) });
  } catch (error) {
    runtime.lastError = error.message;
    upsertFeed({ title: "Gateway Config", time: formatTimestamp(Date.now()), body: t("delete_agent_failed", { error: error.message }) });
  }

  renderAll();
}

function wireEvents() {
  gatewayForm.addEventListener("submit", connectGateway);
  agentEditorForm.addEventListener("submit", handleAgentSubmit);
  todoEditorForm.addEventListener("submit", handleTodoSubmit);

  agentCancelButton.addEventListener("click", () => {
    resetAgentEditor();
    renderAll();
  });

  todoCancelButton.addEventListener("click", () => {
    resetTodoEditor();
    renderAll();
  });

  refreshButton.addEventListener("click", () => {
    if (!runtime.connected) {
      upsertFeed({ title: t("feed_boot_title"), time: formatTimestamp(Date.now()), body: t("refresh_snapshot_blocked") });
      renderAll();
      return;
    }
    fetchSnapshot().catch((error) => {
      runtime.lastError = error.message;
      renderAll();
    });
  });

  disconnectButton.addEventListener("click", () => disconnectGateway(t("manual_disconnect"), { manual: true }));

  commandFeedToggle?.addEventListener("click", () => {
    const collapsed = timelineBody.classList.toggle("is-collapsed");
    commandFeedToggle.textContent = collapsed ? t("expand") : t("collapse");
    commandFeedToggle.setAttribute("aria-expanded", String(!collapsed));
  });

  agentGrid.addEventListener("click", (event) => {
    const button = event.target.closest("[data-agent-id]");
    if (!button) return;
    runtime.selectedAgentId = button.dataset.agentId;
    renderAll();
  });

  agentRegistryList.addEventListener("click", (event) => {
    const button = event.target.closest("[data-agent-action]");
    if (!button) return;

    const agentId = button.dataset.agentRecordId;
    const action = button.dataset.agentAction;

    if (action === "view") {
      runtime.selectedAgentId = agentId;
      renderAll();
      return;
    }

    if (action === "edit") {
      beginEditAgent(agentId);
      return;
    }

    if (action === "delete") {
      deleteGatewayAgent(agentId);
    }
  });

  todoBoardList.addEventListener("click", (event) => {
    const button = event.target.closest("[data-todo-action]");
    if (!button) return;

    const todoId = button.dataset.todoId;
    const action = button.dataset.todoAction;
    const todo = runtime.todos.find((item) => item.id === todoId);
    if (!todo) return;

    if (action === "edit") {
      beginEditTodo(todoId);
      return;
    }

    if (action === "toggle") {
      runtime.todos = runtime.todos.map((item) =>
        item.id === todoId ? { ...item, status: item.status === "done" ? "todo" : "done" } : item,
      );
      saveConfig();
      upsertFeed({
        title: "Todo Board",
        time: formatTimestamp(Date.now()),
        body: t("todo_toggled", { title: todo.title, state: todo.status === "done" ? t("todo_state_open") : t("todo_state_done") }),
      });
      renderAll();
      return;
    }

    if (action === "delete") {
      runtime.todos = runtime.todos.filter((item) => item.id !== todoId);
      if (runtime.todoDraftId === todoId) {
        resetTodoEditor();
      }
      saveConfig();
      upsertFeed({ title: "Todo Board", time: formatTimestamp(Date.now()), body: t("todo_deleted", { title: todo.title }) });
      renderAll();
    }
  });

  refreshAgentButton.addEventListener("click", () => {
    if (!runtime.connected) {
      upsertFeed({ title: t("feed_boot_title"), time: formatTimestamp(Date.now()), body: t("refresh_entities_blocked") });
      renderAll();
      return;
    }
    fetchSnapshot().catch((error) => {
      runtime.lastError = error.message;
      renderAll();
    });
  });
  languageSwitch?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-lang]");
    if (!button) return;
    setLanguage(button.dataset.lang);
  });
  sidebarToggle?.addEventListener("click", () => {
    appShell?.classList.toggle("sidebar-collapsed");
    applyLanguage();
  });
}

function init() {
  const storedConfig = loadConfig();
  const storedSession = loadSessionConnection();
  runtime.language = detectLanguage();
  activeLanguage = runtime.language;
  gatewayUrlInput.value = normalizeGatewayUrl(storedConfig.gatewayUrl || DEFAULT_URL);
  gatewayTokenInput.value = storedSession.token;
  gatewayPasswordInput.value = storedSession.password;
  if (storedSession.gatewayUrl) {
    gatewayUrlInput.value = normalizeGatewayUrl(storedSession.gatewayUrl);
  }
  runtime.todos = storedConfig.todos.map(normalizeTodo);
  applyLanguage();
  connectionHint.textContent = t("origin_hint", { origin: window.location.origin });
  setConnectionState(t("offline"), connectionHint.textContent);
  resetAgentEditor();
  resetTodoEditor();
  renderClock();
  renderAll();
  wireEvents();
  window.setInterval(renderClock, 1000);

  if (storedSession.autoReconnect && gatewayUrlInput.value.trim()) {
    openGatewayConnection({ save: false, reconnect: true });
  }
}

init();
