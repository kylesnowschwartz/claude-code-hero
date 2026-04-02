# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level0Test < HeroTestCase
  def test_verify_passes_with_valid_artifact
    write_file('.claude/hero-journal.md', <<~MD)
      ## First Steps

      I learned how to use the prompt box.
      The @ symbol references files directly.
      Claude can create files on disk when asked.
      This is the fundamental interaction loop.
    MD

    passed, = Hero::Level0.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level0.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_with_too_few_lines
    write_file('.claude/hero-journal.md', <<~MD)
      ## Journal
      One line only.
    MD

    passed, msg = Hero::Level0.new.verify
    refute passed
    assert_match(/non-blank lines/, msg)
  end

  def test_clean_removes_artifact
    path = write_file('.claude/hero-journal.md', 'content')
    assert File.exist?(path)

    Hero::Level0.new.clean
    refute File.exist?(path)
  end

  def test_clean_dry_run_preserves_file
    path = write_file('.claude/hero-journal.md', 'content')
    actions = Hero::Level0.new(dry_run: true).clean
    assert File.exist?(path)
    assert_includes actions.first, 'remove'
  end
end
