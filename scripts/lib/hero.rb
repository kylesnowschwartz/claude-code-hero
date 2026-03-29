# frozen_string_literal: true

require 'json'
require 'fileutils'

module Hero
  SCRIPT_DIR = File.expand_path('..', __dir__)
  PROJECT_ROOT = ENV.fetch('HERO_PROJECT_ROOT', File.expand_path('../..', __dir__))
end

require_relative 'hero/checks'
require_relative 'hero/level'
require_relative 'hero/progress'

Dir[File.join(__dir__, 'hero', 'levels', '*.rb')].each { |f| require f }

require_relative 'hero/statusline'
require_relative 'hero/solver'
