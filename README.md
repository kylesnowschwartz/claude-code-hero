# Claude Code Hero

Learn Claude Code by building real things. One quest at a time.

## What This Is

A Claude Code plugin that teaches you Claude Code through nine progressive D&D-themed quests. Each quest covers one feature and produces a real artifact you keep -- a config file, a hook, a slash command, something that actually works on your machine. You start by exploring the filesystem and end by building your own plugin. The medium is the message: you learn about plugins by using one.

## Quick Start

```bash
git clone https://github.com/kylesnowschwartz/claude-code-hero.git
cd claude-code-hero
claude --plugin-dir . --agent heroguide
```

## The Nine Quests

| Quest | Name | You Learn |
|-------|------|-----------|
| 1 | The Map Room | The `~/.claude/` directory |
| 2 | The Tome of First Instructions | `CLAUDE.md` |
| 3 | The Goblin Lair of Commands | Slash commands |
| 4 | The Warden's Keys | Settings and permissions |
| 5 | The Shapeshifter's Mask | Output styles |
| 6 | The Tripwire Cavern | Hooks |
| 7 | The Skill Quest of Doom | Skills |
| 8 | The Summoner's Circle | Agents |
| 9 | The Artificer's Workshop | Plugins |

## How It Works

- Progress saves to `~/.claude/claude-code-hero.json`
- Each quest produces a real artifact on your filesystem
- Already have a `CLAUDE.md` or existing config? The system recognizes prior work
- Resume anytime: `claude --plugin-dir . --agent heroguide`

## License

MIT
