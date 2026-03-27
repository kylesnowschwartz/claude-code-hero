# frozen_string_literal: true

module Hero
  class Level7 < Level
    number   7
    name     'The Skill Quest of Doom'
    feature  'Skills'
    artifact '.claude/skills/hero-knowledge/SKILL.md'

    SKILL_FILE = '.claude/skills/hero-knowledge/SKILL.md'
    SKILL_DIR = '.claude/skills/hero-knowledge'

    verify do
      file_exists SKILL_FILE
      grep_match SKILL_FILE, 'name:'
      grep_match SKILL_FILE, 'description:'
    end

    clean do
      remove_file SKILL_FILE
      remove_dir_if_empty SKILL_DIR
    end
  end
end
