# frozen_string_literal: true

module Hero
  class Level10 < Level
    number   10
    name     'The Hall of Watchers'
    feature  'Advanced hooks'
    artifact '.claude/settings.json (PreToolUse)'

    SETTINGS = '.claude/settings.json'
    EVENT = %w[hooks PreToolUse].freeze
    # Claude Code accepts both separators, so both pass. The quest asks for a
    # pipe because that is the documented form, not because a comma breaks.
    SEPARATORS = ['|', ','].freeze

    verify do
      file_exists SETTINGS
      json_field_exists SETTINGS, EVENT
      # Shape only -- the checks below own the specific failures, so the
      # pattern here is deliberately one that any hook entry satisfies.
      json_hook_entry_match SETTINGS, EVENT, pattern: '.'

      group = hero_watcher_group
      check_multi_tool_matcher(group)
      check_prompt_hook(group)
    end

    clean do
      json_remove_matching SETTINGS,
                           keys: EVENT,
                           pattern: 'hero',
                           cleanup_keys: [EVENT, %w[hooks]]
    end

    private

    # Prefers the group holding a prompt hook, so a half-built attempt gets the
    # specific complaint about what is wrong rather than "no group found".
    def hero_watcher_group
      groups = Array(JSON.parse(File.read(expand(SETTINGS))).dig(*EVENT)).grep(Hash)
      found = groups.find { |g| prompt_hook_in(g) } ||
              groups.find { |g| g.to_s.match?(/hero/i) } ||
              groups.first
      raise CheckFailed, 'No PreToolUse groups found' unless found

      found
    end

    def prompt_hook_in(group)
      Array(group['hooks']).find { |h| h.is_a?(Hash) && h['type'] == 'prompt' }
    end

    def check_multi_tool_matcher(group)
      matcher = group['matcher'].to_s

      if matcher.empty?
        raise CheckFailed, 'The PreToolUse group needs a "matcher" -- without one it fires on every tool'
      end

      return if SEPARATORS.any? { |sep| matcher.include?(sep) }

      raise CheckFailed,
            "Matcher #{matcher.inspect} only covers one tool. Watch at least two, as in \"Write|Edit\"."
    end

    def check_prompt_hook(group)
      hook = prompt_hook_in(group)
      raise CheckFailed, 'No hook with type "prompt" in the group -- this quest is about the model-backed type' unless
        hook

      return if hook['prompt'].to_s.match?(/hero/i)

      raise CheckFailed, 'The prompt hook needs a "prompt" field mentioning "hero"'
    end
  end
end
