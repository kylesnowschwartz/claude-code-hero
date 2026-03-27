# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level2Test < HeroTestCase
  CLAUDE_MD = '.claude/CLAUDE.md'

  def valid_claude_md
    <<~MD
      # My Instructions

      ## Existing Section
      Some content here.

      ## Hero's Decree
      I shall write clean code.
      I shall test before I ship.
      I shall name things well.

      ## Another Section
      More stuff.
    MD
  end

  def test_verify_passes_with_valid_section
    write_file(CLAUDE_MD, valid_claude_md)
    passed, = Hero::Level2.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level2.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_when_section_missing
    write_file(CLAUDE_MD, "# My Instructions\n\n## Other\nStuff.\n")
    passed, msg = Hero::Level2.new.verify
    refute passed
    assert_match(/not found/, msg)
  end

  def test_verify_fails_with_too_few_content_lines
    write_file(CLAUDE_MD, <<~MD)
      ## Hero's Decree
      Only one line.

      ## Next
    MD
    passed, msg = Hero::Level2.new.verify
    refute passed
    assert_match(/content lines/, msg)
  end

  def test_verify_passes_with_section_at_eof
    write_file(CLAUDE_MD, <<~MD)
      ## Hero's Decree
      Line one.
      Line two.
      Line three.
    MD
    passed, = Hero::Level2.new.verify
    assert passed
  end

  def test_clean_removes_decree_section
    write_file(CLAUDE_MD, valid_claude_md)
    Hero::Level2.new.clean

    content = File.read(File.join(@tmpdir, CLAUDE_MD))
    refute_match(/Hero's Decree/, content)
    assert_match(/Existing Section/, content)
    assert_match(/Another Section/, content)
  end

  def test_clean_preserves_other_sections
    write_file(CLAUDE_MD, valid_claude_md)
    Hero::Level2.new.clean

    content = File.read(File.join(@tmpdir, CLAUDE_MD))
    assert_match(/Some content here/, content)
    assert_match(/More stuff/, content)
  end

  def test_clean_handles_section_at_eof
    write_file(CLAUDE_MD, <<~MD)
      ## Other
      Content.

      ## Hero's Decree
      Line one.
      Line two.
    MD
    Hero::Level2.new.clean

    content = File.read(File.join(@tmpdir, CLAUDE_MD))
    refute_match(/Hero's Decree/, content)
    assert_match(/Other/, content)
  end

  def test_clean_noop_when_section_absent
    write_file(CLAUDE_MD, "## Other\nContent.\n")
    Hero::Level2.new.clean
    content = File.read(File.join(@tmpdir, CLAUDE_MD))
    assert_match(/Other/, content)
  end

  def test_clean_dry_run_preserves_file
    write_file(CLAUDE_MD, valid_claude_md)
    Hero::Level2.new(dry_run: true).clean
    content = File.read(File.join(@tmpdir, CLAUDE_MD))
    assert_match(/Hero's Decree/, content)
  end
end
