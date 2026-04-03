---
description: "Wipe all hero artifacts and reset progress to level 0"
---

Run `ruby scripts/cli.rb clean` from the claude-code-hero plugin directory to remove all hero-specific artifacts and reset progress.

The CLI:
1. Removes standalone hero files (hero-map.md, hero-spell.md, hero-protocol.md, hero-agent.md, hero-knowledge/)
2. Surgically removes hero entries from shared configs (Hero's Decree from CLAUDE.md, permission rules and hooks from settings.json)
3. Resets hero-hook.sh to its placeholder state
4. Resets claude-code-hero.json to level 0

Run with `--dry-run` first to preview what would be removed: `ruby scripts/cli.rb clean --dry-run`
