# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level9Test < HeroTestCase
  def write_plugin(name, content: { 'name' => 'hero-toolkit' })
    manifest = "#{name}/.claude-plugin/plugin.json"
    write_file(manifest, JSON.pretty_generate(content))
    # Create at least one component dir
    FileUtils.mkdir_p(File.join(@tmpdir, name, 'commands'))
    File.join(@tmpdir, manifest)
  end

  def test_verify_passes_with_valid_plugin
    write_plugin('hero-toolkit')
    passed, = Hero::Level9.new.verify
    assert passed
  end

  def test_verify_fails_when_no_plugin_found
    passed, msg = Hero::Level9.new.verify
    refute passed
    assert_match(/No plugin/, msg)
  end

  def test_verify_fails_without_hero_in_name
    write_plugin('hero-toolkit', content: { 'name' => 'my-plugin' })
    # The manifest exists but doesn't contain 'hero'
    passed, = Hero::Level9.new.verify
    refute passed
  end

  def test_verify_fails_without_component_dirs
    manifest = 'hero-toolkit/.claude-plugin/plugin.json'
    write_file(manifest, JSON.pretty_generate({ 'name' => 'hero-toolkit' }))
    # No commands/, skills/, agents/, or hooks/ dirs
    passed, msg = Hero::Level9.new.verify
    refute passed
    assert_match(/component/, msg)
  end

  def test_verify_finds_alternate_names
    write_plugin('hero-plugin')
    passed, = Hero::Level9.new.verify
    assert passed
  end

  # --- Marketplace bonus ---

  def valid_marketplace
    {
      'name' => 'hero-marketplace',
      'owner' => { 'name' => 'A Hero' },
      'plugins' => [{ 'name' => 'hero-toolkit', 'source' => './' }]
    }
  end

  def write_marketplace(data, plugin: 'hero-toolkit')
    write_file("#{plugin}/.claude-plugin/marketplace.json", JSON.pretty_generate(data))
  end

  def test_bonus_is_not_earned_without_a_marketplace
    write_plugin('hero-toolkit')
    refute Hero::Level9.new.bonus_earned?
  end

  def test_bonus_is_earned_with_a_valid_marketplace
    write_plugin('hero-toolkit')
    write_marketplace(valid_marketplace)
    assert Hero::Level9.new.bonus_earned?
  end

  def test_level_still_passes_without_the_bonus
    write_plugin('hero-toolkit')
    passed, msg = Hero::Level9.new.verify

    assert passed, 'the bonus must never gate the level'
    assert_match(/not attempted/, msg)
  end

  def test_pass_message_reports_an_earned_bonus
    write_plugin('hero-toolkit')
    write_marketplace(valid_marketplace)
    _passed, msg = Hero::Level9.new.verify

    assert_match(/bonus \(publishing to a marketplace\): earned/, msg)
  end

  def test_bonus_rejects_a_marketplace_with_no_owner
    write_plugin('hero-toolkit')
    write_marketplace(valid_marketplace.except('owner'))
    refute Hero::Level9.new.bonus_earned?
  end

  def test_bonus_rejects_an_empty_plugins_array
    write_plugin('hero-toolkit')
    write_marketplace(valid_marketplace.merge('plugins' => []))
    refute Hero::Level9.new.bonus_earned?
  end

  def test_bonus_rejects_an_entry_that_names_no_hero_plugin
    write_plugin('hero-toolkit')
    write_marketplace(valid_marketplace.merge('plugins' => [{ 'name' => 'other', 'source' => './' }]))
    refute Hero::Level9.new.bonus_earned?
  end

  def test_bonus_rejects_invalid_json
    write_plugin('hero-toolkit')
    write_file('hero-toolkit/.claude-plugin/marketplace.json', '{ not json')
    refute Hero::Level9.new.bonus_earned?
  end

  def test_clean_removes_the_marketplace_too
    write_plugin('hero-toolkit')
    write_marketplace(valid_marketplace)
    Hero::Level9.new.clean

    refute File.exist?(File.join(@tmpdir, 'hero-toolkit/.claude-plugin/marketplace.json'))
  end

  def test_levels_without_a_bonus_report_a_plain_pass
    refute_predicate Hero::Level3.new, :bonus?
  end

  def test_clean_removes_plugin_manifest
    manifest_path = write_plugin('hero-toolkit')
    Hero::Level9.new.clean
    refute File.exist?(manifest_path)
  end

  def test_clean_dry_run_preserves_files
    manifest_path = write_plugin('hero-toolkit')
    Hero::Level9.new(dry_run: true).clean
    assert File.exist?(manifest_path)
  end
end
