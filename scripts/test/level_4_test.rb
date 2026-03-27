# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level4Test < HeroTestCase
  def valid_settings
    {
      'permissions' => {
        'allow' => ['Bash(git:*)'],
        'ask' => ['Bash(git push:*)'],
        'deny' => ['Bash(git push --force:*)']
      }
    }
  end

  def test_verify_passes_with_all_three_rules
    write_settings(valid_settings)
    passed, = Hero::Level4.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level4.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_when_allow_rule_missing
    settings = valid_settings
    settings['permissions']['allow'] = []
    write_settings(settings)

    passed, msg = Hero::Level4.new.verify
    refute passed
    assert_match(/allow/, msg)
  end

  def test_verify_fails_when_deny_rule_missing
    settings = valid_settings
    settings['permissions'].delete('deny')
    write_settings(settings)

    passed, msg = Hero::Level4.new.verify
    refute passed
    assert_match(/deny/, msg)
  end

  def test_clean_removes_hero_rules
    write_settings(valid_settings)
    Hero::Level4.new.clean

    data = read_json('.claude/settings.json')
    assert_empty data.fetch('permissions', {})
  end

  def test_clean_preserves_non_hero_rules
    settings = valid_settings
    settings['permissions']['allow'] << 'Bash(npm:*)'
    write_settings(settings)

    Hero::Level4.new.clean

    data = read_json('.claude/settings.json')
    assert_includes data['permissions']['allow'], 'Bash(npm:*)'
    refute_includes data['permissions']['allow'], 'Bash(git:*)'
  end

  def test_clean_dry_run_preserves_file
    write_settings(valid_settings)
    Hero::Level4.new(dry_run: true).clean

    data = read_json('.claude/settings.json')
    assert_includes data['permissions']['allow'], 'Bash(git:*)'
  end
end
