# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level8Test < HeroTestCase
  PROJECT_AGENT = '.claude/agents/hero-agent.md'
  USER_AGENT = '.claude/agents/hero-agent.md' # under HOME

  def valid_agent
    <<~MD
      ---
      name: hero-agent
      description: A brave hero agent
      color: green
      model: haiku
      allowedTools:
        - Read
      ---

      You are a hero.

      <example>
      user: Help me quest
      assistant: I shall guide you.
      </example>
    MD
  end

  def agent_without(field)
    fields = {
      'name' => 'name: hero-agent',
      'description' => 'description: A hero',
      'color' => 'color: green',
      'model' => 'model: haiku',
      'allowedTools' => "allowedTools:\n  - Read"
    }
    fields.delete(field)
    "---\n#{fields.values.join("\n")}\n---\n<example>\nfoo\n</example>\n"
  end

  def agent_without_example
    "---\nname: hero-agent\ndescription: A hero\ncolor: green\n" \
      "model: haiku\nallowedTools:\n  - Read\n---\nNo examples.\n"
  end

  def test_verify_passes_with_user_agent
    write_file(USER_AGENT, valid_agent)
    passed, = Hero::Level8.new.verify
    assert passed
  end

  def test_verify_passes_with_project_agent
    # Project agents are under cwd, not HOME. For this test, create under HOME
    # since that's what the test harness controls.
    write_file(USER_AGENT, valid_agent)
    passed, = Hero::Level8.new.verify
    assert passed
  end

  def test_verify_fails_when_file_missing
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_without_name
    write_file(USER_AGENT, agent_without('name'))
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/name/, msg)
  end

  def test_verify_fails_without_description
    write_file(USER_AGENT, agent_without('description'))
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/description/, msg)
  end

  def test_verify_fails_without_color
    write_file(USER_AGENT, agent_without('color'))
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/color/, msg)
  end

  def test_verify_fails_without_model
    write_file(USER_AGENT, agent_without('model'))
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/model/, msg)
  end

  def test_verify_fails_without_allowed_tools
    write_file(USER_AGENT, agent_without('allowedTools'))
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/allowedTools/, msg)
  end

  def test_verify_fails_without_example
    write_file(USER_AGENT, agent_without_example)
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/example/, msg)
  end

  def test_clean_removes_user_agent
    path = write_file(USER_AGENT, valid_agent)
    Hero::Level8.new.clean
    refute File.exist?(path)
  end

  def test_clean_dry_run_preserves_file
    path = write_file(USER_AGENT, valid_agent)
    Hero::Level8.new(dry_run: true).clean
    assert File.exist?(path)
  end
end
