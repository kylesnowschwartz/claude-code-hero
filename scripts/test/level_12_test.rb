# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level12Test < HeroTestCase
  WORKFLOW = '.claude/workflows/hero-warband.js'

  def valid_workflow(name: 'hero-warband', agents: 1, fan_out: 'pipeline')
    calls = Array.new(agents) { |i| "  #{fan_out}(items, x => agent('scout #{i}'))" }.join("\n")
    <<~JS
      export const meta = {
        name: '#{name}',
        description: 'Send scouts out',
        phases: [{ title: 'Scout' }],
      }

      const items = ['a', 'b']
      #{calls}
    JS
  end

  def write_workflow(source, path: WORKFLOW)
    write_file(path, source)
  end

  # --- Verification ---

  def test_verify_passes_with_a_valid_workflow
    write_workflow(valid_workflow)
    passed, msg = Hero::Level12.new.verify
    assert passed, msg
  end

  def test_verify_accepts_parallel_instead_of_pipeline
    write_workflow(valid_workflow(fan_out: 'parallel'))
    passed, msg = Hero::Level12.new.verify
    assert passed, msg
  end

  def test_verify_accepts_any_hero_prefixed_filename
    write_workflow(valid_workflow, path: '.claude/workflows/hero-scouts.js')
    passed, msg = Hero::Level12.new.verify
    assert passed, msg
  end

  def test_verify_fails_without_the_directory
    passed, msg = Hero::Level12.new.verify
    refute passed
    assert_match(/Missing directory/, msg)
  end

  def test_verify_fails_when_no_hero_workflow_exists
    write_file('.claude/workflows/other.js', valid_workflow)
    passed, msg = Hero::Level12.new.verify

    refute passed
    assert_match(/No hero-\*\.js workflow/, msg)
  end

  def test_verify_fails_without_a_meta_block
    write_workflow("const items = []\npipeline(items, x => agent('go'))\n")
    passed, msg = Hero::Level12.new.verify

    refute passed
    assert_match(/no `export const meta/, msg)
  end

  def test_verify_fails_when_meta_name_lacks_the_hero_mark
    write_workflow(valid_workflow(name: 'warband'))
    passed, msg = Hero::Level12.new.verify

    refute passed
    assert_match(/needs to contain "hero"/, msg)
  end

  def test_verify_fails_without_any_agent_call
    write_workflow(<<~JS)
      export const meta = { name: 'hero-warband', description: 'x' }
      pipeline(items, x => x)
    JS
    passed, msg = Hero::Level12.new.verify

    refute passed
    assert_match(/never calls agent\(\)/, msg)
  end

  # The cost cap is the lesson, so it is enforced rather than suggested.
  def test_verify_rejects_more_than_three_agents
    write_workflow(valid_workflow(agents: 4))
    passed, msg = Hero::Level12.new.verify

    refute passed
    assert_match(/four|4 times/i, msg)
    assert_match(/three or fewer/, msg)
  end

  def test_verify_allows_exactly_three_agents
    write_workflow(valid_workflow(agents: 3))
    passed, msg = Hero::Level12.new.verify
    assert passed, msg
  end

  def test_verify_fails_when_agents_never_fan_out
    write_workflow(<<~JS)
      export const meta = { name: 'hero-warband', description: 'x' }
      const one = await agent('scout')
    JS
    passed, msg = Hero::Level12.new.verify

    refute passed
    assert_match(/never pipeline\(\) or parallel\(\)/, msg)
  end

  # --- Cleanup ---

  def test_clean_removes_the_workflow_and_directory
    write_workflow(valid_workflow)
    Hero::Level12.new.clean

    refute File.exist?(File.join(@tmpdir, WORKFLOW))
    refute File.directory?(File.join(@tmpdir, '.claude/workflows'))
  end

  def test_clean_preserves_other_workflows
    write_workflow(valid_workflow)
    write_file('.claude/workflows/other.js', '// keep me')
    Hero::Level12.new.clean

    refute File.exist?(File.join(@tmpdir, WORKFLOW))
    assert File.exist?(File.join(@tmpdir, '.claude/workflows/other.js'))
  end

  def test_clean_dry_run_preserves_everything
    write_workflow(valid_workflow)
    Hero::Level12.new(dry_run: true).clean

    assert File.exist?(File.join(@tmpdir, WORKFLOW))
  end
end
