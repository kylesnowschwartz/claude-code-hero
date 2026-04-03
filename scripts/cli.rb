#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, 'lib'))
require 'hero'

module Hero
  module CLI
    def self.run(args)
      command = args.shift
      case command
      when 'status'     then cmd_status
      when 'verify'     then cmd_verify(args)
      when 'clean'      then cmd_clean(args)
      when 'levels'     then cmd_levels
      when 'solve'      then cmd_solve(args)
      when 'statusline' then cmd_statusline
      when 'music'      then cmd_music(args)
      else
        warn 'Usage: ruby scripts/cli.rb {status|verify [N]|clean [--dry-run]|levels|solve N|statusline|music toggle}'
        exit 1
      end
    end

    def self.cmd_status
      progress = Progress.new
      progress.reconcile!
      puts JSON.pretty_generate(progress.to_h)
    end

    MUSIC_TRANSITIONS = { 2 => true }.freeze

    def self.cmd_verify(args)
      level_num = args.shift&.to_i
      levels = level_num ? [level_num] : Hero::Level.numbers
      results = verify_levels(levels)
      all_pass = results.all? { |r| r[:passed] }

      puts JSON.pretty_generate({ results: results })
      exit 1 unless all_pass
    end

    def self.verify_levels(levels)
      levels.filter_map do |num|
        klass = Level.find(num)
        unless klass
          warn "Level #{num}: SKIP (not defined)"
          next
        end
        passed, message = klass.new.verify
        warn "Level #{num}: #{passed ? 'PASS' : 'FAIL'} - #{message}"
        transition_music if passed && MUSIC_TRANSITIONS[num]
        { level: num, passed: passed, message: message }
      end
    end

    def self.transition_music
      script = File.join(__dir__, 'play-music.sh')
      system('pkill', '-f', 'afplay.*assets/audio', err: File::NULL, out: File::NULL)
      system('pkill', '-f', 'play-music.sh', err: File::NULL, out: File::NULL)
      sleep 0.5
      system('bash', script)
    end

    def self.cmd_clean(args)
      dry_run = args.include?('--dry-run')
      all_actions = Level.all.reverse.flat_map do |klass|
        klass.new(dry_run: dry_run).clean
      end

      if dry_run
        all_actions << 'would reset progress'
      else
        Progress.new.reset!
        all_actions << 'reset progress'
      end

      puts JSON.pretty_generate({ actions: all_actions, dry_run: dry_run })
    end

    def self.cmd_levels
      puts JSON.pretty_generate(Level.all.map { |k| k.new.to_h })
    end

    def self.cmd_solve(args)
      level_num = args.shift&.to_i
      valid_levels = Hero::Level.numbers
      unless level_num && valid_levels.include?(level_num)
        warn "Usage: ruby scripts/cli.rb solve N  (where N is #{valid_levels.first}-#{valid_levels.last})"
        exit 1
      end

      Solver.solve(level_num)
      results = verify_levels(Hero::Level.numbers.select { |n| n <= level_num })
      all_pass = results.all? { |r| r[:passed] }

      puts JSON.pretty_generate({ solved_through: level_num, results: results })
      exit 1 unless all_pass
    end

    def self.cmd_music(args)
      action = args.shift
      unless action == 'toggle'
        warn 'Usage: ruby scripts/cli.rb music toggle'
        exit 1
      end

      progress = Progress.new
      current = progress.music?
      new_state = !current
      progress.set_music!(new_state)
      puts JSON.pretty_generate({ music: new_state })
    end

    def self.cmd_statusline
      begin
        $stdin.read_nonblock(65_536)
      rescue StandardError
        nil
      end
      progress = Progress.new
      puts Statusline.new(progress).render
    end
  end
end

Hero::CLI.run(ARGV.dup)
