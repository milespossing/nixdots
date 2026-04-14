---
name: desktop-notify
description: Send desktop notifications to keep the user informed about task progress, completions, errors, and important events. Use when running long tasks, completing work, or encountering issues that need attention.
---

# Desktop Notifications

Send desktop notifications via `notify-send` so the user stays informed
even when the terminal is not in focus.

## When to Notify

- **Task completion** — after finishing a multi-step task or a long-running operation
- **Errors or failures** — build failures, test failures, or unexpected errors
- **Waiting for input** — when you need the user's attention for a decision
- **Long operations** — before starting something that will take a while

Do **not** notify for trivial actions (reading files, small edits, quick lookups).

## How to Notify

```bash
notify-send \
  --app-name "Copilot" \
  --urgency <low|normal|critical> \
  --icon <icon-name> \
  "<Title>" \
  "<Body>"
```

### Urgency Levels

| Level      | When to use                                   |
| ---------- | --------------------------------------------- |
| `low`      | Informational: task done, status updates       |
| `normal`   | Default: completions, waiting for input        |
| `critical` | Errors, failures, or things needing action now |

### Icon Names

Use freedesktop icon names (Papirus-Dark is installed):

| Scenario             | Icon                              |
| -------------------- | --------------------------------- |
| Task complete        | `dialog-positive`                 |
| Error / failure      | `dialog-error`                    |
| Warning              | `dialog-warning`                  |
| Waiting for input    | `dialog-question`                 |
| Build / compile      | `applications-engineering`        |
| Test results         | `checkbox-checked`                |
| Git / version control| `git`                             |
| General info         | `dialog-information`              |

### Examples

```bash
# Task completed successfully
notify-send --app-name "Copilot" --urgency low --icon dialog-positive \
  "Task Complete" "Refactored auth module — 3 files changed, all tests pass."

# Build failed
notify-send --app-name "Copilot" --urgency critical --icon dialog-error \
  "Build Failed" "src/parser.rs:42 — type mismatch in parse_token()"

# Waiting for user decision
notify-send --app-name "Copilot" --urgency normal --icon dialog-question \
  "Input Needed" "Should I use PostgreSQL or SQLite for the new service?"

# Long operation starting
notify-send --app-name "Copilot" --urgency low --icon applications-engineering \
  "Building" "Running full test suite — this may take a few minutes."
```

## Dunst Rules

Notifications with `--app-name "Copilot"` are styled by the system's dunst
config. The `--urgency` flag controls border color:
- **low**: subtle grey border
- **normal**: mauve/purple border
- **critical**: red border, persists until dismissed
