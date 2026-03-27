# frozen_string_literal: true

module Hero
  class Level3 < Level
    number   3
    name     'The Goblin Lair of Commands'
    feature  'Slash commands'
    artifact '~/.claude/commands/hero-spell.md'

    SPELL = '~/.claude/commands/hero-spell.md'

    verify do
      file_exists SPELL
      grep_match SPELL, '^---'
      grep_match SPELL, 'description:'
      grep_match SPELL, 'argument-hint:'
      grep_match SPELL, '\$ARGUMENTS'
    end

    clean do
      remove_file SPELL
    end
  end
end
