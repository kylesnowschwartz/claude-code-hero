---
name: level-8-the-summoners-circle
description: "Claude Code Hero Level 8: The Summoner's Circle -- create an agent definition with frontmatter and system prompt"
---

## Objective

Create an **agent** definition -- a `.md` file with agent frontmatter and a system prompt body.

## Why This Matters

Skills are knowledge. Agents are beings. An agent is an autonomous subprocess with its own system prompt, its own tool access, and its own purpose. When Claude encounters a task that matches an agent's description, it can delegate to that agent entirely -- spawning a focused subprocess that works independently and returns with results.

Agents are how Claude Code scales. Instead of one conversation doing everything, you dispatch specialists. A code reviewer that only looks at diffs. A test writer that only touches test files. A documentation agent that reads code and produces docs. Each one scoped, focused, and safe.

## The Quest

A circular chamber. Runes etched into the floor in concentric rings. At the center, an empty space. This is a summoning circle. Whatever you inscribe here will have a life of its own.

Agents live as `.md` files. They can go in a project's `.claude/agents/` directory, in `~/.claude/agents/` for global access, or in a plugin's `agents/` directory. Each one follows the pattern you've seen before: YAML frontmatter on top, content below. But the frontmatter carries more weight here.

Your task:

- Create an agent `.md` file in a location that makes sense for your use case
- Add **YAML frontmatter** with at least `name` and `description`
- In the `description`, include at least one `<example>` block showing a user prompt that should trigger this agent
- Write a **system prompt** in the body -- this is the agent's personality, purpose, and instructions
- Choose a specialization: code review, test generation, documentation, refactoring, or something you'll actually use

The `description` with `<example>` blocks is how Claude decides when to dispatch your agent. Without examples, Claude has to guess. With them, it knows.

Optionally, add a `disallowedTools` field to the frontmatter to restrict what the agent can do. An agent that only reviews code doesn't need write access. An agent that generates docs doesn't need to run shell commands. Constraints make agents safer and more predictable.

## Hints

### Hint 1

An agent is a `.md` file in an `agents/` directory. The simplest location for experimenting is `~/.claude/agents/`. The filename (minus `.md`) becomes how you reference the agent.

```
~/.claude/agents/
  my-reviewer.md
```

### Hint 2

The frontmatter needs `name` and `description`. The description should include `<example>` blocks so Claude knows when to activate the agent.

```markdown
---
name: test-writer
description: |
  Generates tests for code changes.

  <example>
  write tests for the new auth module
  </example>

  <example>
  add test coverage for the payment service
  </example>
---
```

### Hint 3

Here's a complete agent definition:

```markdown
---
name: code-reviewer
description: |
  Reviews code for bugs, style issues, and potential improvements.

  <example>
  review the changes in this PR
  </example>

  <example>
  check this function for edge cases
  </example>
disallowedTools:
  - Edit
  - Write
  - Bash
---

You are a code reviewer. Your job is to read code and provide feedback. You do not modify files.

When reviewing, focus on:
- Logic errors and edge cases
- Naming clarity
- Unnecessary complexity
- Missing error handling

Be specific. Reference line numbers. Suggest improvements but do not implement them.
```

The `disallowedTools` field prevents the agent from using tools it shouldn't need. A reviewer that can't edit files is a reviewer you can trust to only review.

To test: invoke the agent by name with `/agent-name` or ask Claude something that matches the example prompts.

## Verification

### Filesystem Check

- Look for `.md` files in common agent locations:
  - `~/.claude/agents/*.md`
  - `.claude/agents/*.md` (in any project)
- At least one agent `.md` file must exist

### Content Check

- The file has valid YAML frontmatter (content between `---` delimiters at the top)
- Frontmatter contains a `name` field with a non-empty value
- Frontmatter contains a `description` field
- The `description` includes at least one `<example>` block
- The body below the frontmatter contains a system prompt (not empty)

## Connection

The circle glows. Something stirs inside it -- your creation. It has a name, a purpose, and the autonomy to act on both.

The guide leading you through these quests? That's an agent. `heroguide.md`. You've been talking to one this entire time.

Commands. Skills. Hooks. Agents. You've forged every component. Each one powerful on its own. But what if you could bind them together into a single artifact? A package that anyone could install and use?

One final quest remains.
