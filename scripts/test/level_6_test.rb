# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level6Test < HeroTestCase
  SETTINGS = '.claude/settings.json'

  def hero_hook_path
    File.join(@tmpdir, 'scripts/hero-hook.sh')
  end

  # A second clone of the plugin elsewhere on disk. Level 6 must ignore it.
  def stray_hook_path
    File.join(@tmpdir, 'Code/claude-code-hero/scripts/hero-hook.sh')
  end

  def hook_group(command)
    { 'hooks' => [{ 'type' => 'command', 'command' => command }] }
  end

  def valid_settings
    {
      'hooks' => {
        'UserPromptSubmit' => [hook_group("bash #{hero_hook_path}")]
      }
    }
  end

  def valid_hook_script
    <<~BASH
      #!/usr/bin/env bash
      # Hero Hook
      # YOUR COMMAND:
      echo "hero: Magic Missile fired" >> /tmp/hero-hook-log.txt
      # ============================================================
    BASH
  end

  def placeholder_hook_script
    <<~BASH
      #!/usr/bin/env bash
      # YOUR COMMAND:
      echo "hero: REPLACE_ME - edit hero-hook.sh with your command" >>/tmp/hero-hook-log.txt
      # ===
    BASH
  end

  def setup
    super
    FileUtils.mkdir_p(File.dirname(hero_hook_path))
    File.write(hero_hook_path, valid_hook_script)
  end

  def write_stray_hook(content)
    FileUtils.mkdir_p(File.dirname(stray_hook_path))
    File.write(stray_hook_path, content)
  end

  # --- Verification ---

  def test_verify_passes_with_valid_setup
    write_settings(valid_settings)
    passed, = Hero::Level6.new.verify
    assert passed
  end

  def test_verify_fails_when_settings_missing
    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_without_hooks_section
    write_settings({})
    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(/UserPromptSubmit/, msg)
  end

  def test_verify_fails_without_hero_hook_reference
    write_settings({ 'hooks' => { 'UserPromptSubmit' => [hook_group('bash other.sh')] } })
    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(/hero-hook/, msg)
  end

  def test_verify_fails_on_flat_hook_object
    flat = { 'type' => 'command', 'command' => "bash #{hero_hook_path}" }
    write_settings({ 'hooks' => { 'UserPromptSubmit' => [flat] } })
    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(/nested 'hooks' array/, msg)
  end

  def test_verify_fails_when_hook_script_has_placeholder
    write_settings(valid_settings)
    File.write(hero_hook_path, placeholder_hook_script)
    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(/REPLACE_ME/, msg)
  end

  def test_verify_fails_when_hook_script_missing_hero
    write_settings(valid_settings)
    File.write(hero_hook_path, "#!/usr/bin/env bash\necho 'nothing'\n")
    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(/hero/, msg)
  end

  def test_verify_ignores_a_second_clone_on_disk
    write_settings(valid_settings)
    write_stray_hook(placeholder_hook_script)

    passed, = Hero::Level6.new.verify
    assert passed, 'an unedited copy in another clone must not fail the plugin copy'
  end

  def test_verify_fails_when_only_a_second_clone_was_edited
    write_settings(valid_settings)
    File.write(hero_hook_path, placeholder_hook_script)
    write_stray_hook(valid_hook_script)

    passed, msg = Hero::Level6.new.verify
    refute passed, 'editing another clone must not satisfy the quest'
    assert_match(/REPLACE_ME/, msg)
  end

  def test_verify_fails_when_plugin_hook_script_missing
    write_settings(valid_settings)
    FileUtils.rm_f(hero_hook_path)

    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(%r{Missing file.*scripts/hero-hook\.sh}, msg)
  end

  # --- Cleanup ---

  def test_clean_removes_hero_hook_from_settings
    write_settings(valid_settings)
    Hero::Level6.new.clean

    data = read_json(SETTINGS)
    assert_empty data.fetch('hooks', {})
  end

  def test_clean_preserves_non_hero_hooks
    settings = {
      'hooks' => {
        'UserPromptSubmit' => [
          hook_group("bash #{hero_hook_path}"),
          hook_group('bash other-hook.sh')
        ]
      }
    }
    write_settings(settings)
    Hero::Level6.new.clean

    data = read_json(SETTINGS)
    groups = data['hooks']['UserPromptSubmit']
    assert_equal 1, groups.size
    assert_match(/other-hook/, groups.first['hooks'].first['command'])
  end

  def test_clean_resets_hook_script_to_placeholder
    write_settings(valid_settings)
    Hero::Level6.new.clean

    content = File.read(hero_hook_path)
    assert_match(/REPLACE_ME/, content)
  end

  def test_clean_leaves_a_second_clone_untouched
    write_settings(valid_settings)
    write_stray_hook(valid_hook_script)
    Hero::Level6.new.clean

    assert_equal valid_hook_script, File.read(stray_hook_path),
                 'clean must not write into another clone of the plugin'
  end

  def test_clean_dry_run_preserves_everything
    write_settings(valid_settings)
    Hero::Level6.new(dry_run: true).clean

    data = read_json(SETTINGS)
    refute_empty data['hooks']['UserPromptSubmit']
    content = File.read(hero_hook_path)
    refute_match(/REPLACE_ME/, content)
  end
end
