# frozen_string_literal: true

module Hero
  class Level8 < Level
    number   8
    name     "The Summoner's Circle"
    feature  'Agents'
    artifact 'hero-agent.md'

    USER_AGENT = '~/.claude/agents/hero-agent.md'
    PROJECT_AGENT = '.claude/agents/hero-agent.md'

    verify do
      path = find_hero_agent
      grep_match path, 'description:'
      grep_match path, '<example>'
    end

    clean do
      remove_file USER_AGENT
      remove_file PROJECT_AGENT
    end

    private

    def find_hero_agent
      [USER_AGENT, PROJECT_AGENT].each do |candidate|
        full = expand(candidate)
        return full if File.file?(full)
      end
      raise CheckFailed, 'hero-agent.md not found in .claude/agents/ or ~/.claude/agents/'
    end
  end
end
