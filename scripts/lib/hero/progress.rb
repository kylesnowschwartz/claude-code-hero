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

    def reconcile!
      highest = 0
      (1..9).each do |n|
        klass = Level.find(n)
        next unless klass

        passed, = klass.new.verify
        if passed
          highest = n
          @data['completed'][n.to_s] ||= DateTime.now.new_offset(0).strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      end

      @data['current_level'] = [highest + 1, 10].min if highest >= @data['current_level']
      save!
      self
    end

    def status
      cl = @data['current_level']
      if cl == 1 && @data['completed'].empty?
        'new'
      elsif cl > 9
        'complete'
      else
        'in_progress'
      end
    end

    def highest_passing
      (1..9).select { |n| @data['completed'].key?(n.to_s) }.max || 0
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
      @data = { 'current_level' => 1, 'completed' => {} }
      save!
    end

    def advance!(level)
      @data['completed'][level.to_s] = DateTime.now.new_offset(0).strftime('%Y-%m-%dT%H:%M:%SZ')
      @data['current_level'] = level + 1 if level >= @data['current_level']
      save!
    end

    private

    def load_or_init
      if File.exist?(@path)
        JSON.parse(File.read(@path))
      else
        { 'current_level' => 1, 'completed' => {} }
      end
    end

    def save!
      dir = File.dirname(@path)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      File.write(@path, "#{JSON.pretty_generate(@data)}\n")
    end
  end
end
