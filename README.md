# Claude Code Hero

Learn Claude Code by playing a dungeon crawler. Nine quests, nine real artifacts you keep.

<!-- TODO: Record demo gif and uncomment: ![Demo](docs/demo.gif) -->

## Why

I built this for colleagues who wanted to learn Claude Code but kept bouncing off the docs. Most people plateau at basic chat and CLAUDE.md -- commands, hooks, agents, and plugins go untouched. So I made a D&D-themed quest system that teaches each feature by having you build something real with it. Turns out a dungeon master is a good format for guided learning.

## Install

```bash
git clone https://github.com/kylesnowschwartz/claude-code-hero.git
cd claude-code-hero
bash scripts/install.sh
```

The install script checks for dependencies and offers to install anything missing:

| Dependency | What it does | Install source |
|---|---|---|
| [Ruby](https://www.ruby-lang.org/en/documentation/installation/) | Runs the game engine | Homebrew / apt |
| [jq](https://jqlang.org/download/) | Parses JSON in hook scripts | Homebrew / apt |
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code/getting-started) | The CLI you're learning | Official installer |

macOS and Linux supported. Windows users: use WSL.

## Play

```bash
$ claude --plugin-dir . --agent dungeon-master
```

## The Nine Quests

| Quest | Name | You Learn |
|-------|------|-----------|
| 1 | The Map Room | The `.claude/` directory |
| 2 | The Tome of First Instructions | `CLAUDE.md` |
| 3 | The Goblin Lair of Commands | Slash commands |
| 4 | The Warden's Keys | Settings and permissions |
| 5 | The Shapeshifter's Mask | Output styles |
| 6 | The Tripwire Cavern | Hooks |
| 7 | The Skill Quest of Doom | Skills |
| 8 | The Summoner's Circle | Agents |
| 9 | The Artificer's Workshop | Plugins |

Each quest produces a real artifact on your filesystem. Artifacts from earlier quests feed into later ones -- the spell you build in Level 3 gets a hook in Level 6, and everything bundles into a plugin in Level 9.

## Commands

| Command | What it does |
|---|---|
| `/hero-status` | Show quest progress |
| `/restart` | Wipe all artifacts and start over |
| `/verify` | Check if your current quest is complete |

## How It Works

Progress saves to `.claude/claude-code-hero.json`. The plugin loads a dungeon master agent that guides you through each quest, verifies your work programmatically, and advances you to the next level. Already have a `CLAUDE.md` or existing hooks? The system recognizes prior work.

Resume anytime: `claude --plugin-dir . --agent dungeon-master`

## License

MIT
