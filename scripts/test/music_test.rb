# frozen_string_literal: true

require 'English'
require_relative 'test_helper'
require 'hero'

class MusicTest < HeroTestCase
  PLAY_SCRIPT = File.expand_path('../play-music.sh', __dir__)

  # Progress::DEFAULT_PATH is resolved when the class loads, before the test
  # helper swaps PROJECT_ROOT, so the path has to be passed explicitly.
  def progress_path
    File.join(@tmpdir, '.claude', 'claude-code-hero.json')
  end

  def test_music_is_on_by_default
    assert Hero::Music.enabled?
  end

  def test_disable_then_enable
    Hero::Music.disable!
    refute Hero::Music.enabled?

    Hero::Music.enable!
    assert Hero::Music.enabled?
  end

  def test_toggle_flips_the_state
    Hero::Music.toggle!
    refute Hero::Music.enabled?

    Hero::Music.toggle!
    assert Hero::Music.enabled?
  end

  def test_enable_is_safe_when_already_on
    Hero::Music.enable!
    assert Hero::Music.enabled?
  end

  def test_preference_survives_a_progress_reset
    Hero::Music.disable!
    Hero::Progress.new(path: progress_path).reset!

    refute Hero::Music.enabled?, 'cleaning a playthrough must not turn music back on'
  end

  def test_reset_keeps_other_keys_but_clears_quest_progress
    write_progress({ 'current_level' => 5, 'completed' => { '4' => 'ts' }, 'theme' => 'dark' })
    Hero::Progress.new(path: progress_path).reset!

    data = read_json('.claude/claude-code-hero.json')
    assert_equal 0, data['current_level']
    assert_empty data['completed']
    assert_equal 'dark', data['theme']
  end

  # play-music.sh gates every playback path, so its copy of the flag location
  # has to match the Ruby one.
  def test_play_script_checks_the_same_flag_path
    script = File.read(PLAY_SCRIPT)
    shell_path = "$HOME/.claude/#{Hero::Music::FLAG_NAME}"

    assert_includes script, shell_path,
                    "play-music.sh must check #{shell_path}"
  end

  def test_play_script_exits_without_playing_when_disabled
    Hero::Music.disable!
    out = `HOME=#{@tmpdir} bash #{PLAY_SCRIPT} 2>&1`

    assert_predicate $CHILD_STATUS, :success?
    assert_empty out.strip
    assert_empty `pgrep -f 'afplay.*assets/audio'`.strip
  end
end
