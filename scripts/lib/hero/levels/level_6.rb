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
      json_array_match SETTINGS, %w[hooks UserPromptSubmit], pattern: 'hero-hook'

      script = find_hero_hook
      grep_match script, 'REPLACE_ME', expect_missing: true
      grep_match script, 'hero'
    end

    clean do
      json_remove_matching SETTINGS,
                           keys: %w[hooks UserPromptSubmit],
                           pattern: 'hero-hook',
                           cleanup_keys: [%w[hooks UserPromptSubmit], %w[hooks]]
      reset_hero_hook
    end

    private

    def hook_search_dirs
      [
        Hero::PROJECT_ROOT,
        expand('~/Code'),
        expand('~/Projects'),
        expand('~/Developer'),
        expand('~/src'),
        expand('~/.claude/plugins/cache')
      ]
    end

    def find_hero_hook
      hook_search_dirs.each do |dir|
        next unless File.directory?(dir)

        result = Dir.glob(File.join(dir, '**', 'hero-hook.sh')).find do |path|
          path.include?('claude-code-hero')
        end
        return result if result
      end
      raise CheckFailed, 'hero-hook.sh not found in claude-code-hero plugin'
    end

    def reset_hero_hook
      hook_search_dirs.each do |dir|
        next unless File.directory?(dir)

        Dir.glob(File.join(dir, '**', 'hero-hook.sh')).each do |path|
          next unless path.include?('claude-code-hero')

          reset_file_region path,
                            start_marker: '# YOUR COMMAND:',
                            end_marker: '# ===',
                            replacement: PLACEHOLDER_REGION
        end
      end
    end
  end
end
