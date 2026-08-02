# frozen_string_literal: true

module Hero
  class Level11 < Level
    number   11
    name     'The Oracle Well'
    feature  'MCP servers'
    artifact '.mcp.json'

    CONFIG = '.mcp.json'

    verify do
      file_exists CONFIG
      server = hero_server_entry
      command = server_command(server)
      check_server_responds(command)
    end

    clean do
      remove_hero_server
    end

    private

    def config_data
      JSON.parse(File.read(expand(CONFIG)))
    rescue JSON::ParserError => e
      raise CheckFailed, "#{CONFIG} is not valid JSON: #{e.message}"
    end

    # Both shapes are valid: servers at the top level, or nested under
    # "mcpServers". Accept either so the quest is about MCP, not about guessing
    # which wrapper this file uses.
    def server_map
      data = config_data
      map = data['mcpServers'].is_a?(Hash) ? data['mcpServers'] : data
      raise CheckFailed, "#{CONFIG} holds no server definitions" unless map.is_a?(Hash) && !map.empty?

      map
    end

    def hero_server_entry
      name, server = server_map.find { |key, value| key.to_s.match?(/hero/i) && value.is_a?(Hash) }
      unless name
        raise CheckFailed,
              "No server whose name contains \"hero\" in #{CONFIG}. Found: #{server_map.keys.inspect}"
      end

      server
    end

    def server_command(server)
      command = server['command'].to_s
      raise CheckFailed, 'The hero server needs a "command"' if command.empty?

      args = Array(server['args']).map(&:to_s)
      script = args.find { |a| a.end_with?('.rb') }
      raise CheckFailed, 'The hero server should run hero-oracle-server.rb via "args"' unless script

      resolved = resolve(script)
      raise CheckFailed, "The server script does not exist: #{script}" unless File.file?(resolved)

      [command, *args.map { |a| a == script ? resolved : a }]
    end

    # A project-scoped .mcp.json substitutes shell environment variables only.
    # Claude Code injects neither CLAUDE_PROJECT_DIR nor CLAUDE_PLUGIN_ROOT here,
    # so a path holding either resolves to nothing and the server never starts.
    # Expanding them would let verification pass a config the runtime rejects.
    def resolve(path)
      unresolvable = path.scan(/\$\{(\w+)\}/).flatten.reject { |name| ENV.fetch(name, nil) }
      unless unresolvable.empty?
        raise CheckFailed,
              "#{CONFIG} references #{unresolvable.map { |n| "${#{n}}" }.join(', ')}, which is not set. " \
              'Claude Code substitutes only shell environment variables here, so /mcp reports ' \
              '"Missing environment variables" and the server fails to connect. Use a path instead.'
      end

      expanded = path.gsub(/\$\{(\w+)\}/) { ENV.fetch(::Regexp.last_match(1)) }
      return expanded if expanded.start_with?('/')

      # Relative paths resolve against the working directory Claude Code was
      # launched from, which the quest tells the player to make the project root.
      File.join(Hero::PROJECT_ROOT, expanded)
    end

    # Config alone proves nothing -- a wired server that cannot answer is the
    # failure this level is meant to catch, so the check speaks the protocol.
    def check_server_responds(command)
      tools = McpProbe.tools(command)
      return if tools.any? { |t| t['name'].to_s == 'consult_oracle' }

      raise CheckFailed, "The server started but listed no consult_oracle tool. Got: #{tools.inspect}"
    end

    def remove_hero_server
      path = expand(CONFIG)
      return unless File.exist?(path)

      data = JSON.parse(File.read(path))
      map = data['mcpServers'].is_a?(Hash) ? data['mcpServers'] : data
      removed = map.keys.select { |k| k.to_s.match?(/hero/i) }
      return if removed.empty?

      removed.each { |k| map.delete(k) }
      write_or_remove_config(path, data, map)
      record_action("remove #{removed.join(', ')} from #{CONFIG}")
    end

    def write_or_remove_config(path, data, map)
      return if dry_run?

      data.delete('mcpServers') if data['mcpServers'].is_a?(Hash) && map.empty?
      if data.empty?
        File.delete(path)
      else
        File.write(path, "#{JSON.pretty_generate(data)}\n")
      end
    end
  end
end
