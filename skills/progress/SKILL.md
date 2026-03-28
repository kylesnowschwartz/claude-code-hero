---
name: progress
description: "Claude Code Hero progress report -- shows the learner's quest log with completed, current, and locked quests"
---

# Progress Skill

Display the learner's quest log as a DM-narrated progress summary.

## Steps

### 1. Read Progress and Quest Metadata

Run `ruby scripts/cli.rb status` to get the authoritative state: `{ current_level, completed, highest_passing, status }`.

Run `ruby scripts/cli.rb levels` to get quest metadata (names, features, artifacts).

If the progress file does not exist, respond:

> No quest log found. You haven't begun your journey. Run the dungeon-master to start.

Then stop.

### 2. Build the Quest Log

For each quest, determine its status:

- **COMPLETE**: The level number (as a string key) exists in `completed`. Use the date portion of the ISO 8601 timestamp as the completion date.
- **CURRENT**: The level number equals `current_level` and is not in `completed`.
- **LOCKED**: The level number is greater than `current_level`.

### 3. Present the Quest Log

Open with a line of DM flavor. Something like:

> You unroll the quest log. The parchment shows your journey so far...

Then render a table:

| Quest | Name | Status | Completed |
|-------|------|--------|-----------|
| 1 | The Map Room | COMPLETE | 2026-03-27 |
| 2 | The Tome of First Instructions | COMPLETE | 2026-03-27 |
| 3 | The Goblin Lair of Commands | CURRENT | -- |
| 4 | The Warden's Keys | LOCKED | -- |
| ... | ... | ... | ... |

### 4. Add Context Around the Table

After the table, add brief annotations in DM voice:

- **Completed quests**: A one-line reminder of what they built or discovered. Keep it to a phrase, not a paragraph.
- **Current quest**: A nudge to continue. "The third chamber stands open. Step inside when you're ready."
- **Locked quests**: One or two mysterious hints about what lies deeper. Don't spoil the content -- intrigue only.

Close with an overall progress line: "{N} of 9 chambers conquered. The deeper halls await."

### 5. All Complete

If all nine levels are in `completed` (or `current_level` >= 10), skip the table annotations and instead deliver:

> The quest log is full. Every chamber conquered, every seal broken. You are no longer an adventurer. You are an artificer.

## Guidelines

- Keep the whole response concise. The quest log should feel satisfying to look at, not tedious to read.
- Use the dungeon-master voice for formatting and tone.
- Drop character for exact dates and status values in the table. Resume voice immediately around it.
