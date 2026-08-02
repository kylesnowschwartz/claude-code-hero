# frozen_string_literal: true

require 'open3'
require 'json'

module Hero
  # Starts an MCP stdio server, asks it what tools it offers, and shuts it down.
  # Verifying an MCP level from the config file alone would pass a server that
  # cannot answer, so the check speaks the protocol instead.
  module McpProbe
    TIMEOUT = 10

    def self.tools(command)
      stdout, stderr, finished = capture(command, request_line)
      raise CheckFailed, "The server exited with an error: #{stderr.strip}" unless finished

      parse_tools(stdout, stderr)
    end

    def self.request_line
      "#{JSON.generate({ jsonrpc: '2.0', id: 1, method: 'tools/list' })}\n"
    end

    def self.parse_tools(stdout, stderr)
      line = stdout.each_line.find { |l| l.include?('"result"') }
      unless line
        raise CheckFailed,
              "The server sent no JSON-RPC result. stdout: #{stdout[0, 200].inspect} #{stderr[0, 200]}"
      end

      Array(JSON.parse(line).dig('result', 'tools'))
    rescue JSON::ParserError => e
      raise CheckFailed, "The server's reply was not valid JSON: #{e.message}"
    end

    def self.capture(command, input)
      stdout = +''
      stderr = +''
      finished = false
      Open3.popen3(*command) do |sin, sout, serr, thread|
        sin.write(input)
        sin.close
        finished = !thread.join(TIMEOUT).nil?
        stdout = sout.read.to_s
        stderr = serr.read.to_s
        Process.kill('KILL', thread.pid) unless finished
      end
      [stdout, stderr, finished]
    rescue Errno::ENOENT => e
      raise CheckFailed, "Could not start the server: #{e.message}"
    end
  end
end
