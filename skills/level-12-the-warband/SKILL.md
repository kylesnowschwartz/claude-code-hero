---
name: level-12-the-warband
description: "Claude Code Hero Level 12: The Warband -- write a dynamic workflow that fans work out across agents"
---

## Objective

Write a workflow script at `.claude/workflows/hero-warband.js` that spawns agents and fans work out across them.

## Why This Matters

In the Summoner's Circle you called one companion and waited. That is the whole shape of a subagent: hand off a task, get an answer back.

A **workflow** is the shape above that. It is a script -- real JavaScript, with loops and conditions -- that decides how many agents to spawn, what each one does, and how their results combine. The control flow is deterministic. The work inside each agent is not.

That distinction is the point. When you ask Claude to "review these twelve files," you get one agent's summary of twelve files. When a workflow does it, you get twelve agents that each actually read one file, and a script that decides what to do with the twelve answers.

## The Quest

The circle held one summoning. This chamber holds a war table.

A map, and figures on it. You do not fight — you place. The warband moves where you send it, several at once, and reports back.

### The script

A workflow is a `.js` file. It opens with a `meta` block the runtime reads before running anything:

```javascript
export const meta = {
  name: 'hero-warband',
  description: 'Scout three corners of the dungeon at once',
  phases: [{ title: 'Scout' }],
}
```

That block must be a **plain literal**. No variables, no function calls, no template strings — the runtime reads it before your code executes, so anything computed fails to load.

Below it, the script body. Four things are available:

- **`agent(prompt, opts)`** — spawn a subagent, get its final text back. Pass `{schema}` and you get a validated object instead of a string.
- **`parallel(thunks)`** — run several at once and wait for all of them. A barrier.
- **`pipeline(items, ...stages)`** — run each item through every stage independently, with no waiting between stages. Item A can reach stage 3 while item B is still on stage 1.
- **`log(message)`** — say something to the person watching.

Prefer `pipeline` to `parallel`. A barrier makes every fast item wait for the slowest one, and most of the time nothing needs that.

### Two things that will bite you

**Workflows do not run just because you wrote one.** They need explicit opt-in — the user asks for a workflow by name, uses the `ultracode` keyword, or invokes a skill that runs one. Write a perfect workflow file, ask Claude to "run it," and you may get nothing at all. The file being correct is not the same as the workflow being invoked.

**Every agent is a real model call.** A workflow that fans out to forty agents costs forty agents. Keep your first one to **three at most** — this quest enforces that, and the enforcement is the lesson.

### What to build

Create `.claude/workflows/hero-warband.js`:

- A `meta` block whose `name` contains `hero`
- At least one `agent()` call, and no more than three
- At least one `pipeline()` or `parallel()` call

A shape to start from:

```javascript
export const meta = {
  name: 'hero-warband',
  description: 'Send scouts into three corners of the dungeon',
  phases: [{ title: 'Scout' }],
}

const CORNERS = ['the flooded vault', 'the collapsed stair', 'the singing door']

const reports = await pipeline(
  CORNERS,
  corner => agent(`You are a scout. Describe what you find at ${corner} in two sentences.`,
                  { label: `scout:${corner}`, phase: 'Scout' })
)

log(`${reports.filter(Boolean).length} scouts returned`)
return reports
```

Three corners, three scouts, one line deciding what happens to their answers. That is a workflow.

### Try it

Ask for it by name: "run the hero-warband workflow." Watch `/workflows` to see the scouts appear.

If nothing happens, that is the opt-in gate, not a broken file. Say the word "workflow" explicitly.

## Hints

### Hint 1

The directory may not exist yet:

```bash
mkdir -p .claude/workflows
```

### Hint 2

Scripts are plain JavaScript, not TypeScript. Type annotations, interfaces, and generics all fail to parse. The body runs in an async context, so `await` works at the top level without wrapping anything.

Also unavailable: `Date.now()`, `new Date()` with no arguments, and `Math.random()`. They would make a run unrepeatable, so they throw. Pass timestamps in, or vary things by index.

### Hint 3

`pipeline(items, stage1, stage2)` gives every stage `(previousResult, originalItem, index)`. That third argument is how you label work in later stages without threading the item through the first stage's return value.

## Verification

When you're ready, run `/verify` to check your work.

### Filesystem Check

- A file matching `.claude/workflows/hero-*.js` exists

### Content Check

- It has an `export const meta = {...}` block
- The meta `name` contains `hero`
- It calls `agent()` at least once and at most three times
- It calls `pipeline()` or `parallel()` at least once

## Further Reading

- [Subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) -- the single-agent shape this level builds on

## Connection

The warband scatters across the map and comes back with more than one of them could have carried.

Look at what you have built. A command. A rule. A hook that reacts and a watcher that decides. A skill. An agent. A plugin, published to a marketplace. A tool that did not exist until you connected it. And now a script that commands several agents at once.

You started this dungeon typing sentences into a box. You are ending it writing programs whose instructions are written in English and whose workers think.

Go build something worth commanding a warband for.
