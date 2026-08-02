# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level10Test < HeroTestCase
  SETTINGS = '.claude/settings.json'

  def prompt_hook(text: 'Guard the hero artifacts. Deny deletions, otherwise allow.')
    { 'type' => 'prompt', 'prompt' => text }
  end

  def group(matcher: 'Write|Edit', hooks: [prompt_hook])
    { 'matcher' => matcher, 'hooks' => hooks }
  end

  def settings_with(entry)
    { 'hooks' => { 'PreToolUse' => [entry] } }
  end

  def valid_settings
    settings_with(group)
  end

  # --- Verification ---

  def test_verify_passes_with_a_prompt_hook_and_piped_matcher
    write_settings(valid_settings)
    passed, msg = Hero::Level10.new.verify
    assert passed, msg
  end

  def test_verify_fails_when_settings_missing
    passed, msg = Hero::Level10.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_without_a_pretooluse_event
    write_settings({ 'hooks' => {} })
    passed, msg = Hero::Level10.new.verify
    refute passed
    assert_match(/PreToolUse/, msg)
  end

  def test_verify_fails_on_a_flat_hook_object
    write_settings({ 'hooks' => { 'PreToolUse' => [prompt_hook(text: 'hero guard')] } })
    passed, msg = Hero::Level10.new.verify
    refute passed
    assert_match(/nested 'hooks' array/, msg)
  end

  # Claude Code 2.1.220 splits comma-separated matchers before matching, so a
  # comma is valid config and must not fail the level.
  def test_verify_accepts_a_comma_separated_matcher
    write_settings(settings_with(group(matcher: 'Write,Edit')))
    passed, msg = Hero::Level10.new.verify

    assert passed, msg
  end

  def test_verify_rejects_a_single_tool_matcher
    write_settings(settings_with(group(matcher: 'Write')))
    passed, msg = Hero::Level10.new.verify

    refute passed
    assert_match(/only covers one tool/, msg)
  end

  def test_verify_rejects_a_missing_matcher
    write_settings(settings_with({ 'hooks' => [prompt_hook(text: 'hero guard')] }))
    passed, msg = Hero::Level10.new.verify

    refute passed
    assert_match(/needs a "matcher"/, msg)
  end

  def test_verify_rejects_a_command_hook
    command_hook = { 'type' => 'command', 'command' => 'echo hero' }
    write_settings(settings_with(group(hooks: [command_hook])))
    passed, msg = Hero::Level10.new.verify

    refute passed
    assert_match(/type "prompt"/, msg)
  end

  def test_verify_rejects_a_prompt_without_the_hero_mark
    write_settings(settings_with(group(hooks: [prompt_hook(text: 'Deny risky edits.')])))
    passed, msg = Hero::Level10.new.verify

    refute passed
    assert_match(/mentioning "hero"/, msg)
  end

  def test_verify_ignores_unrelated_pretooluse_groups
    unrelated = { 'matcher' => 'Bash', 'hooks' => [{ 'type' => 'command', 'command' => 'true' }] }
    write_settings({ 'hooks' => { 'PreToolUse' => [unrelated, group] } })

    passed, msg = Hero::Level10.new.verify
    assert passed, msg
  end

  # --- Cleanup ---

  def test_clean_removes_the_hero_group
    write_settings(valid_settings)
    Hero::Level10.new.clean

    assert_empty read_json(SETTINGS).fetch('hooks', {})
  end

  def test_clean_preserves_unrelated_groups
    unrelated = { 'matcher' => 'Bash', 'hooks' => [{ 'type' => 'command', 'command' => 'true' }] }
    write_settings({ 'hooks' => { 'PreToolUse' => [unrelated, group] } })
    Hero::Level10.new.clean

    remaining = read_json(SETTINGS)['hooks']['PreToolUse']
    assert_equal 1, remaining.size
    assert_equal 'Bash', remaining.first['matcher']
  end

  def test_clean_dry_run_preserves_everything
    write_settings(valid_settings)
    Hero::Level10.new(dry_run: true).clean

    refute_empty read_json(SETTINGS)['hooks']['PreToolUse']
  end
end
