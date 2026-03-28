# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level5Test < HeroTestCase
  PROTOCOL = '.claude/rules/hero-protocol.md'

  def valid_protocol
    <<~MD
      ---
      paths:
        - "*.quest"
      ---

      Quest log files (.quest) are in-world artifacts written by the hero.
      When summarizing quest log content, open with this formatted line:

      `* The inscription glows ──────────────────────────`
    MD
  end

  def test_verify_passes_with_valid_artifact
    write_file(PROTOCOL, valid_protocol)
    passed, = Hero::Level5.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level5.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_without_paths
    write_file(PROTOCOL, "---\nfoo: bar\n---\n[HERO PROTOCOL ACTIVE]\n")
    passed, msg = Hero::Level5.new.verify
    refute passed
    assert_match(/paths/, msg)
  end

  def test_verify_fails_without_quest_glob
    write_file(PROTOCOL, "---\npaths:\n  - \"*.rb\"\n---\n[HERO PROTOCOL ACTIVE]\n")
    passed, msg = Hero::Level5.new.verify
    refute passed
    assert_match(/quest/, msg)
  end

  def test_verify_fails_without_canary
    write_file(PROTOCOL, "---\npaths:\n  - \"*.quest\"\n---\nSome instructions.\n")
    passed, msg = Hero::Level5.new.verify
    refute passed
    assert_match(/inscription glows/, msg)
  end

  def test_clean_removes_file
    path = write_file(PROTOCOL, valid_protocol)
    Hero::Level5.new.clean
    refute File.exist?(path)
  end

  def test_clean_dry_run_preserves_file
    path = write_file(PROTOCOL, valid_protocol)
    Hero::Level5.new(dry_run: true).clean
    assert File.exist?(path)
  end
end
