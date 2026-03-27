# frozen_string_literal: true

module Hero
  class Level4 < Level
    number   4
    name     "The Warden's Keys"
    feature  'Settings & permissions'
    artifact '~/.claude/settings.json'

    SETTINGS = '~/.claude/settings.json'

    RULES = {
      %w[permissions allow] => 'Bash\(git:',
      %w[permissions ask] => 'Bash\(git push:',
      %w[permissions deny] => 'Bash\(git push --force:'
    }.freeze

    verify do
      file_exists SETTINGS
      RULES.each do |keys, pattern|
        json_array_match SETTINGS, keys, pattern: pattern
      end
    end

    clean do
      json_remove_from_arrays SETTINGS,
                              removals: [
                                [%w[permissions allow], ['Bash(git:*)']],
                                [%w[permissions ask],   ['Bash(git push:*)']],
                                [%w[permissions deny],  ['Bash(git push --force:*)']]
                              ],
                              cleanup_paths: [%w[permissions allow], %w[permissions ask], %w[permissions deny],
                                              %w[permissions]]
    end
  end
end
