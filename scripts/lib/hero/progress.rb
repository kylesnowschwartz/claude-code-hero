# frozen_string_literal: true

require 'json'
require 'date'

module Hero
  class Progress
    DEFAULT_PATH = File.join(Hero::PROJECT_ROOT, '.claude', 'claude-code-hero.json')

    attr_reader :path, :data

    def initialize(path: DEFAULT_PATH)
      @path = path
      @data = load_or_init
    end

    def current_level = @data['current_level']
    def completed     = @data['completed']
    def music?        = @data.fetch('music', true)

    def set_music!(enabled)
      @data['music'] = enabled
      save!
    end

    def reconcile!
      highest = backfill_completed
      advance_to!(highest) if highest
      save!
      self
    end

    def status
      cl = @data['current_level']
      if cl == Level.min_number && @data['completed'].empty?
        'new'
      elsif cl > Level.max_number
        'complete'
      else
        'in_progress'
      end
    end

    def highest_passing
      Level.numbers.select { |n| @data['completed'].key?(n.to_s) }.max || 0
    end

    def to_h
      {
        current_level: @data['current_level'],
        completed: @data['completed'],
        highest_passing: highest_passing,
        status: status
      }
    end

    def reset!
      @data = { 'current_level' => 0, 'completed' => {} }
      save!
    end

    def advance!(level)
      @data['completed'][level.to_s] = iso8601_now
      @data['current_level'] = level + 1 if level >= @data['current_level']
      save!
    end

    private

    def backfill_completed
      highest = nil
      Level.numbers.each do |n|
        klass = Level.find(n)
        next unless klass

        passed, = klass.new.verify
        if passed
          highest = n
          @data['completed'][n.to_s] ||= iso8601_now
        end
      end
      highest
    end

    def advance_to!(highest)
      next_level = [highest + 1, Level.max_number + 1].min
      @data['current_level'] = next_level if highest >= @data['current_level']
    end

    def iso8601_now
      DateTime.now.new_offset(0).strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    def load_or_init
      defaults = { 'current_level' => 0, 'completed' => {} }
      if File.exist?(@path)
        defaults.merge(JSON.parse(File.read(@path)))
      else
        defaults
      end
    end

    def save!
      dir = File.dirname(@path)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      File.write(@path, "#{JSON.pretty_generate(@data)}\n")
    end
  end
end
