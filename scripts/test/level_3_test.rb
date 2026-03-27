# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level3Test < HeroTestCase
  SPELL = '.claude/commands/hero-spell.md'

  def valid_spell
    <<~MD
      ---
      description: Cast a magic missile at your target
      argument-hint: [target]
      ---

      Fire a magic missile at $ARGUMENTS!
    MD
  end

  def test_verify_passes_with_valid_artifact
    write_file(SPELL, valid_spell)
    passed, = Hero::Level3.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level3.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_without_frontmatter_fence
    write_file(SPELL, "description: foo\n$ARGUMENTS\n")
    passed, msg = Hero::Level3.new.verify
    refute passed
    assert_match(/---/, msg)
  end

  def test_verify_fails_without_description
    write_file(SPELL, "---\nargument-hint: [target]\n---\n$ARGUMENTS\n")
    passed, msg = Hero::Level3.new.verify
    refute passed
    assert_match(/description/, msg)
  end

  def test_verify_fails_without_argument_hint
    write_file(SPELL, "---\ndescription: Cast a spell\n---\n$ARGUMENTS\n")
    passed, msg = Hero::Level3.new.verify
    refute passed
    assert_match(/argument-hint/, msg)
  end

  def test_verify_fails_without_arguments_placeholder
    write_file(SPELL, "---\ndescription: foo\nargument-hint: [target]\n---\nno placeholder\n")
    passed, msg = Hero::Level3.new.verify
    refute passed
    assert_match(/ARGUMENTS/, msg)
  end

  def test_clean_removes_file
    path = write_file(SPELL, valid_spell)
    Hero::Level3.new.clean
    refute File.exist?(path)
  end

  def test_clean_dry_run_preserves_file
    path = write_file(SPELL, valid_spell)
    Hero::Level3.new(dry_run: true).clean
    assert File.exist?(path)
  end
end
