# bazzite-ai-dev Plugin

Claude Code plugin for Bazzite AI development with enforcement agents and development tools.

## Purpose

This plugin provides:

1. **Development skills** for building, testing, and maintaining Bazzite AI
2. **Enforcement agents** that ensure code quality and policy compliance
3. **GitHub MCP integration** for repository operations

## MCP Server

This plugin includes a GitHub MCP server for repository operations.

**Tools available:**

- Issues: `issue_read`, `issue_write`, `add_issue_comment`, `list_issues`, `search_issues`
- Pull requests: `pull_request_read`, `list_pull_requests`, `search_pull_requests`
- Workflows: `list_workflows`, `list_workflow_runs`, `get_workflow_run`, `get_job_logs`
- Repository: `get_file_contents`, `list_commits`, `get_commit`, `list_branches`
- Labels: `get_label`, `list_label`, `label_write`

**Prerequisites:**

- `github-mcp-server` available via direnv (installed in project)
- `GITHUB_TOKEN` environment variable set

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| build | `/bazzite-ai-dev:build` | OS image building with Podman |
| clean | `/bazzite-ai-dev:clean` | Cleanup build artifacts and caches |
| test | `/bazzite-ai-dev:test` | Overlay testing session management |

## Enforcement Agents

These agents are automatically invoked to enforce development policies:

### Blocking Agents (Must Pass)

| Agent | Trigger | Purpose |
|-------|---------|---------|
| policy-enforcer | Before Edit/Write, commits | Verifies all policy compliance |
| root-cause-analyzer | On errors | Mandatory 8-step error analysis |
| testing-validator | Before claiming "working" | Confirms LOCAL testing completed |
| justfile-validator | Editing .just files | Validates non-interactive support |
| pre-commit-guardian | Before git commit | Ensures 100% hook pass rate |
| documentation-validator | Editing docs/*.md | Validates MyST syntax |
| config-integrity-enforcer | Editing ~/.config/* | Blocks editing output configs |
| pixi-lock-enforcer | Editing pixi.lock | Blocks manual lock edits |
| sudo-usage-enforcer | sudo ujust detected | Blocks external sudo elevation |
| overlay-testing-enforcer | just -f testing | Blocks direct justfile testing |

### Advisory Agents

| Agent | Trigger | Purpose |
|-------|---------|---------|
| architecture-advisor | "Why?" questions | Explains immutable OS design |
| buildcache-validator | Build file changes | Analyzes build cache impact |
| code-research | Architectural questions | Deep codebase analysis |
| github-actions | CI status queries | Reports workflow status |

## Usage Examples

```bash
# Build the OS image
/bazzite-ai-dev:build
# Claude will help with image building, troubleshooting, etc.

# Set up testing environment
/bazzite-ai-dev:test
# Claude will guide you through overlay testing setup

# Clean up after development
/bazzite-ai-dev:clean
# Claude will help clean build artifacts and caches
```

## Installation

### Manual Loading

```bash
# Load both plugins for full development experience
claude --plugin-dir ./plugins/bazzite-ai --plugin-dir ./plugins/bazzite-ai-dev
```

### Permanent Configuration

Add to your Claude Code settings:

```json
{
  "plugins": [
    "/path/to/bazzite-ai-testing/plugins/bazzite-ai",
    "/path/to/bazzite-ai-testing/plugins/bazzite-ai-dev"
  ]
}
```

## Development Workflow

1. **Enable overlay testing**: `ujust test overlay enable`
2. **Make changes** to justfiles in `just/` directory
3. **Refresh overlay**: `ujust test overlay refresh`
4. **Test with ujust**: `ujust <your-command>`
5. **Verify LOCAL**: Check systemctl status, journalctl logs
6. **Run pre-commit**: `pre-commit run --all-files`
7. **Commit** (enforcement agents will verify)

## Policies Enforced

- LOCAL system verification required before claiming "working"
- ~/.config files are outputs - edit source code instead
- 100% pre-commit hook pass rate required
- All commands must support non-interactive execution
- .just files must be under 30K (split proactively at 25K)
- Never use `sudo ujust` - handle sudo internally
- Never use `just -f` for testing - use overlay method
- Never edit pixi.lock manually - regenerate via `pixi install`

## Related

- **bazzite-ai**: OS user skills (separate plugin)
- **CLAUDE.md**: Full policy documentation
- **AGENTS.md**: Operational commands and architecture
