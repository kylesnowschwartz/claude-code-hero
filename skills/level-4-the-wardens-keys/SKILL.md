---
name: level-4-the-wardens-keys
description: "Claude Code Hero Level 4: The Warden's Keys -- configure permission rules in ~/.claude/settings.json"
---

## Objective

Configure **permission rules** in `~/.claude/settings.json` to control what Claude Code can and cannot do without asking.

## Why This Matters

Every time Claude asks "May I run this command?" -- that's the permission system. It gates every tool: Bash, Write, Edit, WebFetch, all of them. By default, Claude asks before doing almost anything. That's safe, but slow. The permission model has three tiers -- `allow`, `deny`, and `ask` -- and once you understand them, you stop being interrupted and start being in control.

This is also the safety foundation for everything ahead. Hooks and agents need permissions configured correctly or they'll either stall waiting for approval or run things they shouldn't.

## The Quest

You enter a chamber of locked doors. Dozens of them, floor to ceiling, each one carved with a name: **Bash**, **Write**, **Edit**, **WebFetch**, **mcp**. Behind every door, a power. And in the center of the room, a warden's desk. On it: a ledger.

The ledger is `~/.claude/settings.json`. Every door in this chamber answers to it.

Three columns in the ledger. Three tiers of control:

- **`allow`** -- the door opens without question. Claude acts freely.
- **`deny`** -- the door stays sealed. Claude cannot use the tool at all.
- **`ask`** -- the default. Claude knocks and waits for your approval each time.

Your task:

- Open `~/.claude/settings.json` (create it if it doesn't exist)
- Locate or create the `permissions` object with `allow`, `deny`, and `ask` arrays
- Add at least one **allow rule** to stop Claude from asking about something you trust
- Understand the **tool name syntax** and **glob patterns** used in permission rules

Permission rules use the format `ToolName(pattern)` where the pattern supports globs:

- `Bash(git:*)` -- allow all git commands without asking
- `Bash(npm test:*)` -- allow npm test and its variations
- `Write` -- allow all file writes (use with caution)
- `Bash(ls:*)` -- allow ls commands

Some rules need no pattern at all. `Edit` allows all edits. `WebFetch` allows all fetches.

## Hints

### Hint 1

The file lives at `~/.claude/settings.json`. If it doesn't exist yet, create it. The structure you need is:

```json
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

The `ask` tier is implicit -- anything not in `allow` or `deny` falls through to `ask`.

### Hint 2

Rules follow the pattern `ToolName(command_prefix:*)`. The colon-star is a glob. For Bash commands, the prefix is the command name:

- `Bash(git:*)` matches `git status`, `git commit`, `git push`, everything starting with `git`
- `Bash(npm test:*)` matches `npm test`, `npm test -- --watch`, etc.
- `Bash(cargo:*)` matches all cargo commands

Tools without arguments just use the bare name: `Edit`, `Write`, `WebFetch`.

### Hint 3

Here's a working example with several rules:

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(npm test:*)",
      "Bash(ls:*)",
      "Bash(cat:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)"
    ]
  }
}
```

Pick rules that match your workflow. If you run `git` commands constantly, allow them. If there's something Claude should never touch, deny it.

## Verification

### Filesystem Check

- Path: `~/.claude/settings.json`
- Command: `test -f ~/.claude/settings.json && echo "exists" || echo "missing"`
- The file must exist

### Content Check

- The file contains valid JSON
- A `permissions` object exists at the top level
- The `permissions.allow` array contains at least one entry
- The entry follows the tool name syntax (e.g., `Bash(git:*)`, `Edit`, etc.)

## Connection

The keys are yours. Every door in this chamber answers to your ledger now. You decide what flows freely and what waits for your word.

But there's more than permission in this realm. There's presentation. You've controlled what Claude does. What if you could change how Claude speaks?
