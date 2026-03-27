# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'
require 'open3'

class CLITest < HeroTestCase
  def cli(args)
    cmd = "ruby -Iscripts/lib scripts/cli.rb #{args}"
    stdout, stderr, status = Open3.capture3({ 'HOME' => @tmpdir, 'HERO_PROJECT_ROOT' => @tmpdir }, cmd)
    [stdout, stderr, status]
  end

  def test_levels_returns_all_levels
    stdout, _, status = cli('levels')
    assert status.success?
    data = JSON.parse(stdout)
    assert_equal 9, data.size
    assert_equal 1, data.first['level']
    assert_equal 9, data.last['level']
  end

  def test_levels_returns_valid_json
    stdout, _, status = cli('levels')
    assert status.success?
    data = JSON.parse(stdout)
    data.each do |level|
      assert level.key?('level')
      assert level.key?('name')
      assert level.key?('feature')
      assert level.key?('artifact')
    end
  end

  def test_status_returns_valid_json
    stdout, _, status = cli('status')
    assert status.success?
    data = JSON.parse(stdout)
    assert_includes data.keys, 'current_level'
    assert_includes data.keys, 'completed'
    assert_includes data.keys, 'highest_passing'
    assert_includes data.keys, 'status'
  end

  def test_status_new_player
    stdout, = cli('status')
    data = JSON.parse(stdout)
    assert_equal 1, data['current_level']
    assert_equal 'new', data['status']
  end

  def test_verify_single_level_fails
    _, _, status = cli('verify 1')
    refute status.success?
  end

  def test_verify_single_level_returns_json
    stdout, = cli('verify 1')
    data = JSON.parse(stdout)
    assert data.key?('results')
    assert_equal 1, data['results'].size
    assert_equal false, data['results'].first['passed']
  end

  def test_verify_all_returns_json
    stdout, = cli('verify')
    data = JSON.parse(stdout)
    assert data.key?('results')
    assert_equal 9, data['results'].size
  end

  def test_verify_human_messages_on_stderr
    _, stderr, = cli('verify 1')
    assert_match(/Level 1:/, stderr)
  end

  def test_clean_dry_run_returns_json
    stdout, _, status = cli('clean --dry-run')
    assert status.success?
    data = JSON.parse(stdout)
    assert data.key?('actions')
    assert_equal true, data['dry_run']
  end

  def test_clean_resets_progress
    write_progress({ 'current_level' => 5, 'completed' => { '1' => 'x' } })
    cli('clean')
    data = read_json('.claude/claude-code-hero.json')
    assert_equal 1, data['current_level']
    assert_empty data['completed']
  end

  def test_unknown_command_fails
    _, _, status = cli('bogus')
    refute status.success?
  end
end
