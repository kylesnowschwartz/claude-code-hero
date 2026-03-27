# frozen_string_literal: true

module Hero
  class Level2 < Level
    number   2
    name     'The Tome of First Instructions'
    feature  'CLAUDE.md'
    artifact '.claude/CLAUDE.md'

    CLAUDE_MD = '.claude/CLAUDE.md'
    HEADING = "## Hero's Decree"

    verify do
      file_exists CLAUDE_MD
      grep_match CLAUDE_MD, "## Hero's Decree"
      section_content_lines CLAUDE_MD, heading: HEADING, min: 3
    end

    clean do
      remove_md_section CLAUDE_MD, heading: HEADING
    end
  end
end
