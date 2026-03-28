# frozen_string_literal: true

require 'json'
require 'fileutils'

module Hero
  # QA test fixture: creates minimum artifacts to pass verification for each level.
  # Separate from Level definitions because solving is a testing concern, not a game concern.
  module Solver
    SOLUTIONS = {
      1 => :solve_1_map_room,
      2 => :solve_2_tome,
      3 => :solve_3_commands,
      4 => :solve_4_permissions,
      5 => :solve_5_rules,
      6 => :solve_6_hooks,
      7 => :solve_7_skills,
      8 => :solve_8_agents,
      9 => :solve_9_plugin
    }.freeze

    def self.solve(level)
      (1..level).each do |n|
        method = SOLUTIONS[n]
        raise "No solution defined for level #{n}" unless method

        send(method)
        warn "Level #{n}: SOLVED"
      end
    end

    def self.solve_1_map_room
      write_file('.claude/hero-map.md', <<~MD)
        ## Settings
        Configuration files and permissions.

        ## Commands
        Slash commands as markdown with YAML frontmatter.

        ## Agents
        Agent definitions for autonomous subprocesses.
      MD
    end

    def self.solve_2_tome
      path = expand('.claude/CLAUDE.md')
      if File.exist?(path)
        content = File.read(path)
        File.write(path, "#{content.chomp}\n\n#{heros_decree}") unless content.include?("## Hero's Decree")
      else
        write_file('.claude/CLAUDE.md', heros_decree)
      end
    end

    def self.solve_3_commands
      write_file('.claude/commands/hero-spell.md', <<~MD)
        ---
        description: "Cast a magic missile at a target"
        argument-hint: "<target>"
        ---
        Cast a magic missile at $ARGUMENTS. Describe the arcane energies and the impact.
      MD
    end

    def self.solve_4_permissions
      merge_settings_json { |data| add_permission_rules(data) }
      write_file('.claude/settings.local.json',
                 "{\n  \"permissions\": {\n    \"allow\": []\n  }\n}\n")
    end

    def self.add_permission_rules(data)
      data['permissions'] ||= {}
      data['permissions']['allow'] ||= []
      data['permissions']['ask'] ||= []
      data['permissions']['deny'] ||= []

      append_unique(data['permissions']['allow'], 'Bash(git:*)')
      append_unique(data['permissions']['ask'], 'Bash(git push:*)')
      append_unique(data['permissions']['deny'], 'Bash(git push --force:*)')
    end

    def self.solve_5_rules
      write_file('.claude/rules/hero-protocol.md', <<~MD)
        ---
        paths:
          - "*.quest"
        ---

        Quest log files (.quest) are in-world artifacts written by the hero.
        When summarizing or discussing quest log content, stay in the D&D voice
        and open with "HERO PROTOCOL ACTIVE" before the summary.
      MD
    end

    def self.solve_6_hooks
      merge_settings_json { |data| add_hook_entry(data) }
      activate_hero_hook
    end

    def self.add_hook_entry(data)
      data['hooks'] ||= {}
      data['hooks']['UserPromptSubmit'] ||= []
      return if data['hooks']['UserPromptSubmit'].any? { |h| h.to_s.include?('hero-hook') }

      data['hooks']['UserPromptSubmit'] << {
        'matcher' => '/hero-spell',
        'hooks' => [{ 'type' => 'command', 'command' => 'bash scripts/hero-hook.sh' }]
      }
    end

    def self.activate_hero_hook
      hook_path = File.join(Hero::PROJECT_ROOT, 'scripts', 'hero-hook.sh')
      return unless File.exist?(hook_path)

      content = File.read(hook_path)
      return unless content.include?('REPLACE_ME')

      content.sub!(
        /^echo "hero: REPLACE_ME.*$/,
        'echo "hero: Magic Missile fired at $TARGET" >>/tmp/hero-hook-log.txt'
      )
      File.write(hook_path, content)
    end

    def self.solve_7_skills
      write_file('.claude/skills/hero-knowledge/SKILL.md', <<~MD)
        ---
        name: hero-knowledge
        description: Lore about the hero's dungeon-crawling adventures
        ---
        Knowledge of dungeons, spells, and creatures within.
      MD
    end

    def self.solve_8_agents
      write_file('.claude/agents/hero-agent.md', <<~MD)
        ---
        description: A hero agent that handles dungeon encounters
        ---
        You are a hero agent. Assess threats and report outcomes.

        <example>
        User: "There's a goblin blocking the bridge."
        Action: Dispatch hero-agent to handle the encounter.
        </example>
      MD
    end

    def self.solve_9_plugin
      plugin_dir = File.join(Hero::PROJECT_ROOT, 'hero-toolkit')
      FileUtils.mkdir_p(File.join(plugin_dir, '.claude-plugin'))
      FileUtils.mkdir_p(File.join(plugin_dir, 'commands'))

      write_plugin_manifest(plugin_dir)
      write_plugin_command(plugin_dir)
    end

    def self.write_plugin_manifest(plugin_dir)
      manifest = File.join(plugin_dir, '.claude-plugin', 'plugin.json')
      return if File.exist?(manifest)

      data = {
        'name' => 'hero-toolkit',
        'description' => 'A toolkit forged in the dungeons',
        'version' => '1.0.0'
      }
      File.write(manifest, "#{JSON.pretty_generate(data)}\n")
    end

    def self.write_plugin_command(plugin_dir)
      cmd_file = File.join(plugin_dir, 'commands', 'hero-quest.md')
      return if File.exist?(cmd_file)

      File.write(cmd_file, <<~MD)
        ---
        description: "Check on the hero's quest status"
        ---
        Report the current status of the hero's quest.
      MD
    end

    def self.expand(path)
      if path.start_with?('.claude/')
        File.join(Hero::PROJECT_ROOT, path)
      else
        path
      end
    end

    def self.write_file(relative_path, content)
      full = expand(relative_path)
      FileUtils.mkdir_p(File.dirname(full))
      File.write(full, content)
    end

    def self.merge_settings_json
      path = expand('.claude/settings.json')
      data = File.exist?(path) ? JSON.parse(File.read(path)) : {}
      yield data
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "#{JSON.pretty_generate(data)}\n")
    end

    def self.append_unique(array, value)
      array << value unless array.include?(value)
    end

    def self.heros_decree
      <<~MD
        ## Hero's Decree
        Write clean, readable code above all else.
        Prefer simple solutions over clever abstractions.
        Test before shipping -- untested code is unfinished code.
      MD
    end

    private_class_method :expand, :write_file, :merge_settings_json,
                         :append_unique, :heros_decree,
                         :add_permission_rules, :add_hook_entry,
                         :activate_hero_hook, :write_plugin_manifest,
                         :write_plugin_command
  end
end
