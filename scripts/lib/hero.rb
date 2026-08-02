# frozen_string_literal: true

require 'json'
require 'fileutils'

module Hero
  SCRIPT_DIR = File.expand_path('..', __dir__)
  PROJECT_ROOT = ENV.fetch('HERO_PROJECT_ROOT', File.expand_path('../..', __dir__))

  # The Level 6 hook script ships with this plugin, so its location is derived
  # from the plugin root rather than searched for. A player with a second clone
  # would otherwise have the wrong copy verified and reset.
  # A method, not a constant: tests swap PROJECT_ROOT per case.
  def self.hook_script_path
    File.join(PROJECT_ROOT, 'scripts', 'hero-hook.sh')
  end
end

require_relative 'hero/music'
require_relative 'hero/checks'
require_relative 'hero/level'
require_relative 'hero/progress'

Dir[File.join(__dir__, 'hero', 'levels', '*.rb')].each { |f| require f }

require_relative 'hero/statusline'
require_relative 'hero/solver'
