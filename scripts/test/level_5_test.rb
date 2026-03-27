# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level5Test < HeroTestCase
  VOICE = '.claude/output-styles/hero-voice.md'

  def valid_voice
    <<~MD
      ---
      name: Hero Voice
      description: Speak like a dungeon master
      ---

      You speak in the voice of an ancient sage.
    MD
  end

  def test_verify_passes_with_valid_artifact
    write_file(VOICE, valid_voice)
    passed, = Hero::Level5.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level5.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_without_name
    write_file(VOICE, "---\ndescription: a voice\n---\n")
    passed, msg = Hero::Level5.new.verify
    refute passed
    assert_match(/name/, msg)
  end

  def test_verify_fails_without_description
    write_file(VOICE, "---\nname: Hero Voice\n---\n")
    passed, msg = Hero::Level5.new.verify
    refute passed
    assert_match(/description/, msg)
  end

  def test_clean_removes_file
    path = write_file(VOICE, valid_voice)
    Hero::Level5.new.clean
    refute File.exist?(path)
  end

  def test_clean_dry_run_preserves_file
    path = write_file(VOICE, valid_voice)
    Hero::Level5.new(dry_run: true).clean
    assert File.exist?(path)
  end
end
