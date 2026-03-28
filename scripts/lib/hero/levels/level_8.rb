# frozen_string_literal: true

module Hero
  class Level8 < Level
    number   8
    name     "The Summoner's Circle"
    feature  'Agents'
    artifact '.claude/agents/hero-agent.md'

    AGENT = '.claude/agents/hero-agent.md'

    verify do
      file_exists AGENT
      grep_match AGENT, 'name:'
      grep_match AGENT, 'description:'
      grep_match AGENT, 'color:'
      grep_match AGENT, 'model:'
      grep_match AGENT, 'tools:'
      grep_match AGENT, '<example>'
    end

    clean do
      remove_file AGENT
    end
  end
end
