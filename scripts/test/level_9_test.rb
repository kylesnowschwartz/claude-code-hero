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
