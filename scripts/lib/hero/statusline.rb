# frozen_string_literal: true

module Hero
  class Statusline
    TOTAL_LEVELS = 9

    # ANSI color codes
    CYAN    = "\e[36m"
    YELLOW  = "\e[33m"
    MAGENTA = "\e[35m"
    GREEN   = "\e[32m"
    DIM     = "\e[2m"
    BOLD    = "\e[1m"
    RESET   = "\e[0m"

    def initialize(progress)
      @progress = progress
    end

    def render
      complete? ? render_complete : render_in_progress
    end

    private

    def complete?
      @progress.current_level > TOTAL_LEVELS
    end

    def completed_count
      @progress.completed.size
    end

    def accent
      level = @progress.current_level
      if level > TOTAL_LEVELS then GREEN
      elsif level >= 7 then MAGENTA
      elsif level >= 4 then YELLOW
      else CYAN
      end
    end

    def render_complete
      lines = []
      lines << " ⚔ #{GREEN}#{BOLD}HERO COMPLETE#{RESET}"
      lines << " 🏆 All #{TOTAL_LEVELS} artifacts forged"
      lines.join("\n")
    end

    def render_in_progress
      level = @progress.current_level
      klass = Level.find(level)

      quest_name = klass ? klass._name : 'Unknown Quest'
      feature = klass ? klass._feature : '???'
      artifact = klass ? File.basename(klass._artifact) : '???'

      lines = []
      lines << " 🗡  #{accent}Lvl #{level}/#{TOTAL_LEVELS}#{RESET}  #{accent}#{quest_name}#{RESET}"
      lines << " 🔮 Quest: #{accent}#{feature}#{RESET}"
      lines << " 🏰 Artifacts: #{accent}#{completed_count} forged#{RESET}#{artifact_hint(artifact)}"
      lines.join("\n")
    end

    def artifact_hint(artifact)
      " #{DIM}|#{RESET} Next: #{accent}#{artifact}#{RESET}"
    end
  end
end
