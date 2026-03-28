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
      ---

      You are a hero.

      <example>
      user: Help me quest
      assistant: I shall guide you.
      </example>
    MD
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
    write_file(USER_AGENT, "---\ndescription: A hero\ncolor: green\n---\n<example>\nfoo\n</example>\n")
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/name/, msg)
  end

  def test_verify_fails_without_description
    write_file(USER_AGENT, "---\nname: hero-agent\ncolor: green\n---\n<example>\nfoo\n</example>\n")
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/description/, msg)
  end

  def test_verify_fails_without_color
    write_file(USER_AGENT, "---\nname: hero-agent\ndescription: A hero\n---\n<example>\nfoo\n</example>\n")
    passed, msg = Hero::Level8.new.verify
    refute passed
    assert_match(/color/, msg)
  end

  def test_verify_fails_without_example
    write_file(USER_AGENT, "---\nname: hero-agent\ndescription: A hero\ncolor: green\n---\nNo examples.\n")
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
