# frozen_string_literal: true

module Hero
  class Level5 < Level
    number   5
    name     'The Enchanted Inscription'
    feature  'Rules'
    artifact '.claude/rules/hero-protocol.md'

    PROTOCOL = '.claude/rules/hero-protocol.md'

    verify do
      file_exists PROTOCOL
      grep_match PROTOCOL, 'paths:'
      grep_match PROTOCOL, '\*\.quest'
      grep_match PROTOCOL, 'HERO PROTOCOL ACTIVE'
    end

    clean do
      remove_file PROTOCOL
    end
  end
end
