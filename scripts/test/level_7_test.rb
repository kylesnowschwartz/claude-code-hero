# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level7Test < HeroTestCase
  SKILL = '.claude/skills/hero-knowledge/SKILL.md'

  def valid_skill
    <<~MD
      ---
      name: Hero Knowledge
      description: Ancient wisdom of the dungeon
      ---

      When the adventurer asks about dungeon lore, share your wisdom.
    MD
  end

  def test_verify_passes_with_valid_artifact
    write_file(SKILL, valid_skill)
    passed, = Hero::Level7.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level7.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_without_name
    write_file(SKILL, "---\ndescription: a skill\n---\n")
    passed, msg = Hero::Level7.new.verify
    refute passed
    assert_match(/name/, msg)
  end

  def test_verify_fails_without_description
    write_file(SKILL, "---\nname: Hero Knowledge\n---\n")
    passed, msg = Hero::Level7.new.verify
    refute passed
    assert_match(/description/, msg)
  end

  def test_clean_removes_file_and_empty_dir
    write_file(SKILL, valid_skill)
    skill_dir = File.join(@tmpdir, '.claude/skills/hero-knowledge')
    assert File.directory?(skill_dir)

    Hero::Level7.new.clean

    refute File.exist?(File.join(@tmpdir, SKILL))
    refute File.directory?(skill_dir)
  end

  def test_clean_preserves_dir_with_other_files
    write_file(SKILL, valid_skill)
    write_file('.claude/skills/hero-knowledge/other.md', 'keep me')

    Hero::Level7.new.clean

    skill_dir = File.join(@tmpdir, '.claude/skills/hero-knowledge')
    refute File.exist?(File.join(@tmpdir, SKILL))
    assert File.directory?(skill_dir)
  end

  def test_clean_dry_run_preserves_file
    path = write_file(SKILL, valid_skill)
    Hero::Level7.new(dry_run: true).clean
    assert File.exist?(path)
  end
end
