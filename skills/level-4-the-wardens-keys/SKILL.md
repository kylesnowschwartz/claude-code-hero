---
name: level-4-the-wardens-keys
description: "Claude Code Hero Level 4: The Warden's Keys -- configure permission rules in .claude/settings.json"
---

## Objective

Configure **permission rules** in `.claude/settings.json` to control what Claude Code can and cannot do without asking.

## Why This Matters

Every time Claude asks "May I run this command?" -- that's the permission system. It gates every tool: Bash, Write, Edit, WebFetch, all of them. By default, Claude asks before doing almost anything. That's safe, but slow. The permission model has three tiers -- `allow`, `deny`, and `ask` -- and once you understand them, you stop being interrupted and start being in control.

This is also the safety foundation for everything ahead. Hooks and agents need permissions configured correctly or they'll either stall waiting for approval or run things they shouldn't.

## The Quest

You enter a chamber of locked doors. Dozens of them, floor to ceiling, each one carved with a name: **Bash**, **Write**, **Edit**, **WebFetch**, **mcp**. Behind every door, a power. And in the center of the room, a warden's desk. On it: a ledger.

The ledger is `.claude/settings.json`. Every door in this chamber answers to it.

Three columns in the ledger. Three tiers of control:

- **`allow`** -- the door opens without question. Claude acts freely.
- **`deny`** -- the door stays sealed. Claude cannot use the tool at all.
- **`ask`** -- the default. Claude knocks and waits for your approval each time.

Your task:

Open `.claude/settings.json` (create it if it doesn't exist) and configure three rules that demonstrate all three tiers working together:

1. **Allow** `Bash(git:*)` -- let Claude run git commands freely. This is the most common allow rule.
2. **Ask** `Bash(git push:*)` -- pushes affect the remote. Claude should ask before pushing, even though git is broadly allowed.
3. **Deny** `Bash(git push --force:*)` -- force-pushing rewrites remote history. No one should do this casually, not even you. Deny it outright.

These three rules form a layered policy: git flows freely, pushes require approval, force-pushes are blocked. That's a real permission model, not a checkbox exercise.

Permission rules use the format `ToolName(pattern)` where the pattern supports globs:

- `Bash(git:*)` -- matches `git status`, `git commit`, `git log`, everything starting with `git`
- `Bash(npm test:*)` -- matches `npm test`, `npm test -- --watch`, etc.
- `Write` -- allow all file writes (use with caution)
- `Edit` -- allow all edits. `WebFetch` allows all fetches.

**Tier order matters.** Rules evaluate in a fixed order: **deny first, then ask, then allow**. The first matching rule wins. So `Bash(git push --force:*)` in deny gets checked before `Bash(git push:*)` in ask, which gets checked before `Bash(git:*)` in allow. Deny beats ask beats allow -- always. This is how you build layered policies: broad allow rules at the bottom, carve-outs in ask and deny above them.

### Try it

Before you verify, test the layering. Ask Claude to run `git status` -- it should execute without asking permission. Then ask Claude to run `git push` -- it should prompt you for approval first. That's two tiers working: allow lets git flow, ask gates pushes.

## Hints

### Hint 1

The file lives at `.claude/settings.json`. If it doesn't exist yet, create it. The structure has three arrays:

```json
{
  "permissions": {
    "allow": [],
    "deny": [],
    "ask": []
  }
}
```

Anything not in any list falls through to `ask` behavior by default. But explicit `ask` entries are useful when a broader `allow` rule exists and you want a specific subset to still prompt.

### Hint 2

Rules follow the pattern `ToolName(command_prefix:*)`. The colon-star is a glob. For Bash commands, the prefix is the command name:

- `Bash(git:*)` matches `git status`, `git commit`, `git push`, everything starting with `git`
- `Bash(git push:*)` matches `git push`, `git push origin main`, etc.
- `Bash(git push --force:*)` matches force-push variants specifically

More specific rules override broader ones. So you can allow `git` broadly, then carve out exceptions with `ask` and `deny`.

### Hint 3

Put the three required rules in the right tiers: `Bash(git:*)` in `allow`, `Bash(git push:*)` in `ask`, `Bash(git push --force:*)` in `deny`. Add more rules if you want, but these three are required.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- Path: `.claude/settings.json`
- The file must exist

### Content Checks

Three rules, three tiers:

1. `Bash(git:*)` appears in `permissions.allow`
2. `Bash(git push:*)` appears in `permissions.ask`
3. `Bash(git push --force:*)` appears in `permissions.deny`

## Connection

The keys are yours. Every door in this chamber answers to your ledger now. You decide what flows freely and what waits for your word.

But there's more than permission in this realm. There's presentation. You've controlled what Claude *does*. What if you could change how Claude *speaks*?
