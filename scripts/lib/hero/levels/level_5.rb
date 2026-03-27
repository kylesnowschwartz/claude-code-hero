# frozen_string_literal: true

module Hero
  class Level5 < Level
    number   5
    name     "The Shapeshifter's Mask"
    feature  'Output styles'
    artifact '~/.claude/output-styles/hero-voice.md'

    VOICE = '~/.claude/output-styles/hero-voice.md'

    verify do
      file_exists VOICE
      grep_match VOICE, 'name:'
      grep_match VOICE, 'description:'
    end

    clean do
      remove_file VOICE
    end
  end
end
