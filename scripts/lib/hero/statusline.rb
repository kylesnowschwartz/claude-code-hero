# frozen_string_literal: true

module Hero
  class Statusline
    TOTAL_LEVELS = 9
    BAR_WIDTH = 10

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

    def progress_bar
      filled = (completed_count.to_f / TOTAL_LEVELS * BAR_WIDTH).round
      empty = BAR_WIDTH - filled
      "#{accent}#{'▓' * filled}#{DIM}#{'░' * empty}#{RESET}"
    end

    def pct
      (completed_count.to_f / TOTAL_LEVELS * 100).round
    end

    def render_complete
      bar = "#{GREEN}#{'▓' * BAR_WIDTH}#{RESET}"
      lines = []
      lines << " ⚔ #{GREEN}#{BOLD}HERO COMPLETE#{RESET}                   #{bar} #{GREEN}100%#{RESET}"
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
      lvl = "#{accent}Lvl #{level}/#{TOTAL_LEVELS}#{RESET}"
      bar = "#{progress_bar} #{accent}#{pct}%#{RESET}"
      lines << " ⚔ #{lvl}  #{quest_name}  #{bar}"
      lines << " 🗡 #{DIM}Quest:#{RESET} #{feature}"
      lines << " 🏰 #{DIM}Artifacts:#{RESET} #{completed_count} forged#{artifact_hint(artifact)}"
      lines.join("\n")
    end

    def artifact_hint(artifact)
      " #{DIM}|#{RESET} Next: #{accent}#{artifact}#{RESET}"
    end
  end
end
