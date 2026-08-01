# frozen_string_literal: true

module Hero
  class Level6 < Level
    number   6
    name     'The Tripwire Cavern'
    feature  'Hooks'
    artifact '.claude/settings.json (hooks)'

    SETTINGS = '.claude/settings.json'
    PLACEHOLDER_REGION = <<~'SH'.chomp
      #
      # Examples:
      #   echo "hero: Magic Missile fired at $TARGET ($(date))" >> /tmp/hero-hook-log.txt
      #   osascript -e "display notification \"Magic Missile fired at $TARGET\" with title \"Claude Code Hero\""
      #
      echo "hero: REPLACE_ME - edit hero-hook.sh with your command" >>/tmp/hero-hook-log.txt
    SH

    verify do
      file_exists SETTINGS
      json_field_exists SETTINGS, %w[hooks UserPromptSubmit]
      json_hook_entry_match SETTINGS, %w[hooks UserPromptSubmit], pattern: 'hero-hook'

      script = Hero.hook_script_path
      file_exists script
      grep_match script, 'REPLACE_ME', expect_missing: true
      grep_match script, 'hero'
    end

    clean do
      json_remove_matching SETTINGS,
                           keys: %w[hooks UserPromptSubmit],
                           pattern: 'hero-hook',
                           cleanup_keys: [%w[hooks UserPromptSubmit], %w[hooks]]
      reset_file_region Hero.hook_script_path,
                        start_marker: '# YOUR COMMAND:',
                        end_marker: '# ===',
                        replacement: PLACEHOLDER_REGION
    end
  end
end
