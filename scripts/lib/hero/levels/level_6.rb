# frozen_string_literal: true

module Hero
  class Level6 < Level
    number   6
    name     'The Tripwire Cavern'
    feature  'Hooks'
    artifact '~/.claude/settings.json (hooks)'

    SETTINGS = '~/.claude/settings.json'
    HOOK_SEARCH_DIRS = %w[
      ~/Code
      ~/Projects
      ~/Developer
      ~/src
      ~/.claude/plugins/cache
    ].freeze
    PLACEHOLDER_LINE = 'echo "hero: REPLACE_ME - edit hero-hook.sh with your command" >>/tmp/hero-hook-log.txt'

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

    def find_hero_hook
      HOOK_SEARCH_DIRS.each do |dir|
        expanded = expand(dir)
        next unless File.directory?(expanded)

        result = Dir.glob(File.join(expanded, '**', 'hero-hook.sh')).find do |path|
          path.include?('claude-code-hero')
        end
        return result if result
      end
      raise CheckFailed, 'hero-hook.sh not found in claude-code-hero plugin'
    end

    def reset_hero_hook
      HOOK_SEARCH_DIRS.each do |dir|
        expanded = expand(dir)
        next unless File.directory?(expanded)

        Dir.glob(File.join(expanded, '**', 'hero-hook.sh')).each do |path|
          next unless path.include?('claude-code-hero')

          reset_file_region path,
                            start_marker: '# YOUR COMMAND:',
                            end_marker: '# ===',
                            replacement: PLACEHOLDER_LINE
        end
      end
    end
  end
end
