---
name: level-11-the-oracle-well
description: "Claude Code Hero Level 11: The Oracle Well -- connect an MCP server and gain a new tool"
---

## Objective

Create `.mcp.json` and connect the **Oracle** -- an MCP server shipped with this plugin -- so Claude gains a tool it did not have before.

## Why This Matters

Every power you have built so far reshaped what Claude already does. Commands package prompts. Skills package knowledge. Hooks intercept events. All of it steers a fixed set of tools.

MCP adds tools.

That is the difference. A server speaking the Model Context Protocol hands Claude capabilities that were never compiled in -- your company's ticket system, a database, a build server, a piece of hardware. Claude discovers the tools at startup, sees their names and arguments, and calls them like any built-in.

## The Quest

At the bottom of the hall, a well. Something at the bottom answers when spoken to -- not in a voice you recognise, and not always helpfully. The dungeon calls it the Oracle.

It has been down there the whole time. Nobody wired the rope.

### The server

This plugin ships one: `scripts/hero-oracle-server.rb`. Open it. It is about a hundred lines of Ruby and no dependencies, and reading it is the fastest way to understand what MCP actually is.

There is no magic in it. It reads lines of JSON from standard input, and writes lines of JSON to standard output. That is the entire stdio transport. It answers three methods:

- **`initialize`** -- the handshake. Protocol version, capabilities, who the server is.
- **`tools/list`** -- what tools it offers. Claude calls this at startup, which is how the tool appears in a session.
- **`tools/call`** -- run one. The Oracle's single tool is `consult_oracle`.

You can talk to it yourself, no Claude involved:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ruby scripts/hero-oracle-server.rb
```

A JSON line comes back describing `consult_oracle`. That is what Claude sees.

### The four transports

The Oracle uses **stdio** -- Claude Code launches it as a child process and talks over the pipes. It is the right choice for anything local: a script, a database on your machine, a tool you wrote.

The other three reach servers you did not start:

- **HTTP** -- a REST endpoint with token auth
- **SSE** -- a hosted server over server-sent events, usually with OAuth
- **WebSocket** -- bidirectional streaming for real-time work

Same protocol, different pipe. A server you run locally today can move behind HTTP later without Claude noticing.

### What to build

Create `.mcp.json` in the project root. It maps server names to how to start them:

```json
{
  "mcpServers": {
    "hero-oracle": {
      "command": "ruby",
      "args": ["scripts/hero-oracle-server.rb"]
    }
  }
}
```

- The server name must contain `hero`
- `command` is the executable, `args` carries the path to `hero-oracle-server.rb`

**The path is where this level trips people.** A relative path resolves against the working directory Claude Code was launched from -- not the project root, and not the location of `.mcp.json`. Start Claude Code from the project root and `scripts/hero-oracle-server.rb` works. Start it from `scripts/` and the same config fails.

You may be tempted to reach for a variable to make that robust:

```json
"args": ["${CLAUDE_PROJECT_DIR}/scripts/hero-oracle-server.rb"]
```

**That does not work here.** `.mcp.json` substitutes ordinary shell environment variables, and Claude Code does not set `CLAUDE_PROJECT_DIR` for it -- that variable is injected into hook commands, a different system. `${CLAUDE_PLUGIN_ROOT}` fails the same way; it is only set for an `.mcp.json` that ships inside a plugin. Use either and `/mcp` reports:

```
[Warning] [hero-oracle] mcpServers.hero-oracle: Missing environment variables: CLAUDE_PROJECT_DIR
hero-oracle · ✘ failed
```

So: a relative path from the project root, or an absolute path if you want it to survive being launched from anywhere. If you later move the server into a plugin, `${CLAUDE_PLUGIN_ROOT}` becomes the right answer -- that is what Level 9's packaging buys you.

One name to avoid: `workspace` is reserved by Claude Code and will collide with its own internal server.

### Try it

MCP servers connect at startup, so this one needs a restart. Exit and run `claude --continue` to come back to this conversation.

On the way back you get a prompt you have not seen before:

```
New MCP server found in this project: hero-oracle
❯ 1. Use this MCP server
  2. Use this and all future MCP servers in this project
  3. Continue without using this MCP server
```

A server is code from your project that Claude Code is about to execute, so it asks once per new server. **Choose 1.** Choose 3 and the config is fine, the server is fine, and nothing appears anyway -- which looks exactly like a broken level.

Then check `/mcp`. `hero-oracle` should be listed as connected with 1 tool. Ask Claude to consult the Oracle about your quest -- it will call `mcp__hero-oracle__consult_oracle` and the well will answer.

If it doesn't appear, run the server by hand with the echo command above. If it answers there and not in Claude, the fault is in `.mcp.json`, not the server -- check the path.

## Hints

### Hint 1

`.mcp.json` goes in the project root, next to `.claude/`, not inside it. Both locations work, but the root is the conventional one and the one this quest checks.

### Hint 2

`scripts/hero-oracle-server.rb` is all you need if you start Claude Code from the project root. If you would rather the config not depend on that, take the absolute path instead -- ask Claude, or run:

```bash
ls "$(pwd)/scripts/hero-oracle-server.rb"
```

Either form passes. What fails is a variable nothing sets.

### Hint 3

Tool names arrive namespaced: `mcp__<server>__<tool>`. So the Oracle's tool is `mcp__hero-oracle__consult_oracle`. That prefix is also what you would match on in a `PreToolUse` hook if you wanted the watcher from the last level to guard MCP calls too.

## Verification

When you're ready, run `/verify` to check your work.

### Config Check

- `.mcp.json` exists in the project root and is valid JSON
- A server whose name contains `hero` is defined
- It has a `command`, and `args` pointing at a `.rb` file that exists
- The path uses no `${VARIABLE}` that is unset in your shell -- the same thing that would make the server fail to connect

### Live Check

Verification does not stop at the config. It starts your server, sends it a real `tools/list` request, and requires `consult_oracle` in the reply. A server that is wired but broken fails this level -- which is the only honest way to check that a tool works.

## Further Reading

- [MCP](https://docs.anthropic.com/en/docs/claude-code/mcp) -- official docs on configuring servers, transports, and authentication

## Connection

The rope goes down. Something takes the other end.

You have spent this whole dungeon teaching Claude to use its tools better. This is the first time you gave it a new one -- and the Oracle is a toy, a hundred lines that answers nonsense. The shape is the point. Swap the answers for your deploy pipeline and nothing else about the wiring changes.
