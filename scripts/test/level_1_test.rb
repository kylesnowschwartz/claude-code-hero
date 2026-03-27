# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level1Test < HeroTestCase
  def test_verify_passes_with_valid_artifact
    write_file('.claude/hero-map.md', <<~MD)
      # Hero Map

      ## Section One
      Content here.

      ## Section Two
      More content.

      ## Section Three
      Even more.
    MD

    passed, = Hero::Level1.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level1.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_with_too_few_headings
    write_file('.claude/hero-map.md', <<~MD)
      # Hero Map

      ## Only One
      Content.

      ## Only Two
      More.
    MD

    passed, msg = Hero::Level1.new.verify
    refute passed
    assert_match(/headings/, msg)
  end

  def test_clean_removes_artifact
    path = write_file('.claude/hero-map.md', 'content')
    assert File.exist?(path)

    Hero::Level1.new.clean
    refute File.exist?(path)
  end

  def test_clean_dry_run_preserves_file
    path = write_file('.claude/hero-map.md', 'content')
    actions = Hero::Level1.new(dry_run: true).clean
    assert File.exist?(path)
    assert_includes actions.first, 'remove'
  end
end
