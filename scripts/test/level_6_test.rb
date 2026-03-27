# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level6Test < HeroTestCase
  SETTINGS = '.claude/settings.json'

  def hero_hook_path
    File.join(@tmpdir, 'Code/claude-code-hero/scripts/hero-hook.sh')
  end

  def valid_settings
    {
      'hooks' => {
        'UserPromptSubmit' => [
          { 'command' => "bash #{hero_hook_path}" }
        ]
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
    # Level 6 searches for hero-hook.sh under search dirs. Put it where find_file can find it.
    FileUtils.mkdir_p(File.dirname(hero_hook_path))
    File.write(hero_hook_path, valid_hook_script)
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
    write_settings({ 'hooks' => { 'UserPromptSubmit' => [{ 'command' => 'bash other.sh' }] } })
    passed, msg = Hero::Level6.new.verify
    refute passed
    assert_match(/hero-hook/, msg)
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
          { 'command' => "bash #{hero_hook_path}" },
          { 'command' => 'bash other-hook.sh' }
        ]
      }
    }
    write_settings(settings)
    Hero::Level6.new.clean

    data = read_json(SETTINGS)
    hooks = data['hooks']['UserPromptSubmit']
    assert_equal 1, hooks.size
    assert_match(/other-hook/, hooks.first['command'])
  end

  def test_clean_resets_hook_script_to_placeholder
    write_settings(valid_settings)
    Hero::Level6.new.clean

    content = File.read(hero_hook_path)
    assert_match(/REPLACE_ME/, content)
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
