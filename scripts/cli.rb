#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, 'lib'))
require 'hero'

module Hero
  module CLI
    def self.run(args)
      command = args.shift
      case command
      when 'status'  then cmd_status
      when 'verify'  then cmd_verify(args)
      when 'clean'   then cmd_clean(args)
      when 'levels'  then cmd_levels
      when 'solve'   then cmd_solve(args)
      else
        warn 'Usage: ruby scripts/cli.rb {status|verify [N]|clean [--dry-run]|levels|solve N}'
        exit 1
      end
    end

    def self.cmd_status
      progress = Progress.new
      progress.reconcile!
      puts JSON.pretty_generate(progress.to_h)
    end

    def self.cmd_verify(args)
      level_num = args.shift&.to_i
      levels = level_num ? [level_num] : (1..9).to_a
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
        { level: num, passed: passed, message: message }
      end
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
      unless level_num&.between?(1, 9)
        warn 'Usage: ruby scripts/cli.rb solve N  (where N is 1-9)'
        exit 1
      end

      Solver.solve(level_num)
      results = verify_levels((1..level_num).to_a)
      all_pass = results.all? { |r| r[:passed] }

      puts JSON.pretty_generate({ solved_through: level_num, results: results })
      exit 1 unless all_pass
    end
  end
end

Hero::CLI.run(ARGV.dup)
