---
name: level-10-the-hall-of-watchers
description: "Claude Code Hero Level 10: The Hall of Watchers -- add a PreToolUse prompt hook with a multi-tool matcher"
---

## Objective

Add a **`PreToolUse`** hook to `.claude/settings.json` that watches more than one tool and uses the **`prompt`** hook type.

## Why This Matters

In the Tripwire Cavern you built a hook that ran a shell script and logged a line. That is the simple half of the system: an event fires, a command runs.

The other half decides things. A `PreToolUse` hook sits between Claude and the tool it is about to use, and it can allow, deny, or ask -- per call, based on what the tool was actually asked to do. That is the difference between a tripwire and a guard.

And the guard does not have to be a shell script. It can be a model.

## The Quest

Past the cavern, a hall. Statues line both walls -- watchers, carved mid-turn, eyes following the doors. They are not traps. Traps fire at anything that touches them. These things *look*, and then they decide.

You are going to carve one.

### The matcher

Your Level 6 hook fired on every prompt because `UserPromptSubmit` takes no matcher. `PreToolUse` does, and the matcher is where most people's first advanced hook dies.

**Matchers are regular expressions, not globs and not lists.** To watch two tools:

```json
"matcher": "Write|Edit"
```

A comma works too -- `"Write,Edit"` is split into a list before matching -- but the pipe is what the documentation uses, and older versions of Claude Code accepted only the pipe. Write the pipe.

The part worth real caution is that **the match is a full match, not a substring**. A matcher of `"Edi"` does not match `Edit`. Neither does `"rit"` match `Write`. If you are used to config formats where a fragment matches, this will surprise you:

```json
"matcher": "Edi"     // matches nothing
"matcher": "Edit"    // matches Edit
"matcher": "Edi.*"   // matches Edit, and anything else starting with Edi
```

It is a regular expression, so anchors and metacharacters work: `"^Write$"` and `"Wr.*te"` both match `Write`.

This matters because a matcher that matches nothing fails **silently**. An unmatched group is a completely normal state -- most groups don't match most events -- so there is nothing for Claude Code to warn about. A hook that does nothing looks exactly like a hook that isn't there, which is why the matcher deserves more suspicion than the rest of the structure combined.

### The type

Level 6 used `"type": "command"` -- fast, deterministic, good for a check you can write as a shell test.

This quest uses `"type": "prompt"`. Instead of running a script, Claude Code hands the event to a model along with the text you wrote, and the model's answer becomes the hook's decision. It is the type to reach for when the rule is a judgement rather than a test: "does this edit touch something the hero swore to protect?" is not a `grep`.

There are three others you should know exist:

- **`agent`** -- a full tool-using agent. It can read files and run commands before deciding. Powerful and slow; save it for decisions worth the wait.
- **`mcp_tool`** -- hands the decision to an MCP tool.
- **`http`** -- posts the event to a URL, for logging or an external policy service.

### What to build

Add a `PreToolUse` entry to `.claude/settings.json`. Same shape you learned in the Tripwire Cavern -- the event holds matcher groups, each group holds a nested `hooks` array -- with two changes: the group carries a `matcher`, and the hook is a `prompt`.

- The **matcher** must cover at least two tools, pipe-separated
- The hook's **`type`** must be `"prompt"`
- The hook's **`prompt`** must mention `hero` -- the mark every artifact in this dungeon carries

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "The hero swore an oath to guard this realm. If this change would delete a file the hero built, deny it and say why. Otherwise allow it."
          }
        ]
      }
    ]
  }
}
```

### Try it

Hooks hot-reload. Ask Claude to write or edit a file and watch for the watcher to weigh in before the tool runs.

Then try to make it deny something. Ask Claude to delete one of your hero artifacts. If your prompt is written clearly, the watcher refuses and tells you why -- and the tool never runs.

If nothing happens at all, suspect the matcher before anything else. Print it and check that each name is spelled in full and exactly: the match is whole-string, so one wrong character means the group never fires and never complains.

## Hints

### Hint 1

You already have `hooks.UserPromptSubmit` in `settings.json` from Level 6. `PreToolUse` sits beside it under the same `hooks` object -- you are adding a key, not replacing one:

```json
{
  "hooks": {
    "UserPromptSubmit": [ ... ],
    "PreToolUse": [ ... ]
  }
}
```

### Hint 2

The group shape is identical to Level 6's. The only new part is the `matcher` field on the group itself, alongside the nested `hooks` array:

```json
{
  "matcher": "Write|Edit",
  "hooks": [ { "type": "prompt", "prompt": "..." } ]
}
```

### Hint 3

Write the prompt like an instruction to a careful colleague, not a regex. It gets read by a model, so it can reason about intent: what to look for, what to do when it finds it, and what to do otherwise. Say what should happen in both cases -- a prompt that only describes the bad case leaves the good case undefined.

## Verification

When you're ready, run `/verify` to check your work.

### Config Check

- `.claude/settings.json` has a `hooks.PreToolUse` array
- One group mentions `hero`
- That group has a `matcher` covering at least two tools (a pipe is expected; a comma is accepted, as Claude Code accepts both)
- That group's nested `hooks` array holds an entry with `"type": "prompt"`
- That entry's `prompt` mentions `hero`

## Further Reading

- [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) -- official docs on hook events, types, matchers, and decision control

## Connection

The watcher turns its head. It has an opinion now, and the power to act on it.

Look at the difference between the two hooks you own. The tripwire in the cavern reacts -- something happened, so something else happens. The watcher in this hall decides -- something is *about* to happen, and it gets a vote.

That vote is the whole reason the hook system exists. Everything else is plumbing.
