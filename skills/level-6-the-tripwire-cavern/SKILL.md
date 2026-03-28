---
name: level-6-the-tripwire-cavern
description: "Claude Code Hero Level 6: The Tripwire Cavern -- add a working hook to .claude/settings.json"
---

## Objective

Add a working **hook** to `.claude/settings.json` that fires automatically on a Claude Code event.

## Why This Matters

Everything so far has been reactive. You type a command, Claude responds. You set a permission, Claude obeys. But hooks make Claude Code event-driven. They fire when something happens -- before a tool runs, after a tool completes, when a session ends -- and they can validate, log, transform, or extend behavior without you lifting a finger.

Hooks are the automation layer. They're also the hardest concept in this progression so far. Take it slow.

## The Quest

You descend into a cavern. The floor is wrong. Pressure plates everywhere, connected to mechanisms in the walls by thin wires. Step on one and something activates. Not an attack -- a response. Automated. Precise. Indifferent to who triggered it.

This is the hook system.

Hooks live in `.claude/settings.json` under the `hooks` key. Here's the structure:

```json
{
  "hooks": {
    "EventName": [
      {
        "type": "command",
        "command": "shell command to execute"
      }
    ]
  }
}
```

The top-level `hooks` object maps **event names** to arrays of hook objects. Each hook object has two required fields:

- **`type`** -- always `"command"` for now. This tells Claude Code to run a shell command.
- **`command`** -- the shell command to execute when the hook fires. Anything you'd type in a terminal.

Some events also support a **`matcher`** field that filters *which* occurrences trigger the hook (e.g., `PreToolUse` can match on tool names like `"Bash"` or `"Write"`). But not all events support matchers -- `UserPromptSubmit` doesn't. When an event has no matcher support, the hook fires on every occurrence, and your script decides whether to act.

The events are the moments hooks fire:

- **`UserPromptSubmit`** -- when a prompt is submitted, including slash commands. No matcher support.
- **`PreToolUse`** -- before Claude uses a tool. Matcher filters by tool name (e.g., `"Bash"`, `"Edit"`).
- **`PostToolUse`** -- after a tool completes. Same matcher support as PreToolUse.
- **`Stop`** -- when Claude finishes a response. No matcher support.

There are others (`SessionStart`, `SessionEnd`, `Notification`), but these four cover most use cases.

Remember the spell you forged in the Goblin Lair? `/hero-spell` -- your magic missile command. It's been sitting quietly in `.claude/commands/`, waiting to be invoked. Time to give it a tripwire.

### The script

This plugin ships a hook script that does the plumbing for you: `scripts/hero-hook.sh`. Open it and read it. It:

1. Reads JSON from stdin (Claude Code passes event data this way)
2. Checks if the prompt starts with `/hero-spell`
3. Exits silently if it doesn't match -- other prompts pass through untouched
4. Runs **your command** if it matches

There's a `REPLACE_ME` line in the middle. That's your edit. Replace it with a command that fires when your spell is cast:

macOS notification: `osascript -e "display notification \"Magic Missile fired at $TARGET\" with title \"Claude Code Hero\""`

Cross-platform log: `echo "hero: Magic Missile fired at $TARGET ($(date))" >> /tmp/hero-hook-log.txt`

The `$TARGET` variable is already set for you -- it's whatever the caster aimed at (e.g., `/hero-spell the goblin king` sets TARGET to `the goblin king`).

### The config

Once you've edited the script, wire it into `.claude/settings.json`:

- Add a `hooks` object if one doesn't exist
- Inside it, add a **`UserPromptSubmit`** key with an array containing one hook object
- Set `type` to `"command"`
- Set `command` to run the script: `bash <path-to-plugin>/scripts/hero-hook.sh`

The path to the script depends on where this plugin is installed. Ask Claude to help you find it, or use `find` to locate `hero-hook.sh`.

Since `UserPromptSubmit` hooks fire on every prompt, the script handles filtering. When the prompt isn't `/hero-spell`, the script exits 0 and Claude Code continues normally. When it matches, the script runs your command and blocks the prompt from reaching Claude -- no API call wasted on a side effect.

### Try it

Hooks are hot-reloaded -- no restart needed. Type `/hero-spell the goblin king` right now.

If you used the macOS notification, a system notification pops up. If you used the log file, check it: `cat /tmp/hero-hook-log.txt`. Either way, notice what *didn't* happen -- no API call. The hook intercepted the prompt, ran your command, and blocked it from reaching Claude. Zero tokens spent.

If nothing happened, check two things: does `.claude/settings.json` have the `hooks.UserPromptSubmit` entry? Does the `command` path point to the actual location of `hero-hook.sh`?

That's the tripwire pattern. Event fires, script reacts, side effect happens, prompt never reaches the model.

## Hints

### Hint 1

The placeholder in `scripts/hero-hook.sh` is the line that reads:

```bash
echo "hero: REPLACE_ME - edit hero-hook.sh with your command" >> /tmp/hero-hook-log.txt
```

Replace it with one of these (or anything that contains "hero"):

```bash
echo "hero: Magic Missile fired at $TARGET ($(date))" >> /tmp/hero-hook-log.txt
```

```bash
osascript -e "display notification \"Magic Missile fired at $TARGET\" with title \"Claude Code Hero\""
```

### Hint 2

Your `settings.json` already has `permissions` from Level 4. The `hooks` key sits alongside it at the top level. You're merging into an existing file, not replacing it:

```json
{
  "permissions": { ... },
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "bash /path/to/scripts/hero-hook.sh"
      }
    ]
  }
}
```

To find the script's path, run: `find / -name "hero-hook.sh" -path "*/claude-code-hero/*" 2>/dev/null`

### Hint 3

The `hooks` key sits alongside `permissions` at the top level of `settings.json`. You're merging into an existing file, not replacing it. Replace `/path/to/claude-code-hero` in the `command` field with the actual path where this plugin is installed.

## Verification

When you're ready, run `/verify` to check your work.

### Config Check

- `.claude/settings.json` must exist
- A `hooks` object exists at the top level
- `hooks.UserPromptSubmit` contains at least one hook object
- The hook object has `type` set to `"command"`
- The `command` field references `hero-hook.sh`

### Script Check

- `scripts/hero-hook.sh` in the plugin directory must NOT contain `REPLACE_ME`
- The script must contain the word `hero` (your replacement command)

## Further Reading

- [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) -- official docs on hook events, configuration, input/output formats, and automation patterns

## Connection

Your traps are set. Events trigger. Responses fire. A spell from Level 3 now has a tripwire from Level 6. The cavern hums with mechanisms that activate on their own, responding to moments you defined.

Look at what you've built so far. A command with `$ARGUMENTS`. A rule that activates by path. A hook that reacts to the command. Each piece connects to the others. And the pattern keeps repeating.

Next: knowledge that awakens on its own. Not a trap. Not a spell. Something that surfaces when the situation demands it, without being asked.
