---
description: "QA: solve levels 1 through N by creating minimum passing artifacts"
argument-hint: "<level-number>"
---
Run `ruby scripts/cli.rb solve $ARGUMENTS` from the claude-code-hero plugin directory to create the minimum artifacts needed to pass verification for levels 1 through the specified level.

This is a QA testing tool -- it creates stub artifacts that pass verification checks without going through the actual quest flow. Useful for testing level interactions, cleanup logic, and the heroguide agent at any point in the progression.
