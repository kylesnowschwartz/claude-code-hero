#!/usr/bin/env ruby
# frozen_string_literal: true

# The Oracle -- a minimal MCP server over stdio, shipped with this plugin so
# Level 11 has a real tool to connect rather than a config file to imagine.
#
# Speaks JSON-RPC 2.0, one message per line on stdin, one response per line on
# stdout. Anything it wants to say to a human goes to stderr, because stdout
# carries the protocol.
#
# Implements the three methods a client needs to discover and call a tool:
# initialize, tools/list, tools/call.

require 'json'

module HeroOracle
  PROTOCOL_VERSION = '2024-11-05'

  ANSWERS = [
    'The path you fear is the shorter one.',
    'Yes, but not for the reason you think.',
    'Ask again after you have read the error message.',
    'No. The dungeon has already decided.',
    'Two doors. Both are the same door.',
    'The artifact you seek is in the directory you skipped.',
    'It will work. It will not keep working.',
    'You are holding it upside down.'
  ].freeze

  TOOLS = [
    {
      name: 'consult_oracle',
      description: 'Ask the Oracle a yes-or-no question about your quest and receive a cryptic answer.',
      inputSchema: {
        type: 'object',
        properties: {
          question: { type: 'string', description: 'The question to put to the Oracle.' }
        },
        required: ['question']
      }
    }
  ].freeze

  class Server
    def run(input: $stdin, output: $stdout)
      input.each_line do |line|
        line = line.strip
        next if line.empty?

        response = handle_line(line)
        next unless response

        output.puts(JSON.generate(response))
        output.flush
      end
    end

    private

    def handle_line(line)
      request = JSON.parse(line)
      dispatch(request)
    rescue JSON::ParserError => e
      error_response(nil, -32_700, "Parse error: #{e.message}")
    end

    # Notifications have no id and expect no response.
    def dispatch(request)
      id = request['id']
      return nil if id.nil?

      case request['method']
      when 'initialize' then result(id, initialize_result)
      when 'tools/list' then result(id, { tools: TOOLS })
      when 'tools/call' then result(id, call_tool(request['params']))
      when 'ping'       then result(id, {})
      else error_response(id, -32_601, "Method not found: #{request['method']}")
      end
    end

    def initialize_result
      {
        protocolVersion: PROTOCOL_VERSION,
        capabilities: { tools: {} },
        serverInfo: { name: 'hero-oracle', version: '1.0.0' }
      }
    end

    def call_tool(params)
      params ||= {}
      return unknown_tool(params['name']) unless params['name'] == 'consult_oracle'

      question = params.dig('arguments', 'question').to_s
      { content: [{ type: 'text', text: answer_for(question) }] }
    end

    def unknown_tool(name)
      { content: [{ type: 'text', text: "The Oracle knows no tool named #{name.inspect}." }], isError: true }
    end

    # Deterministic: the same question always gets the same answer, so the
    # Oracle sounds like it means it.
    def answer_for(question)
      return 'Silence. You asked nothing.' if question.strip.empty?

      ANSWERS[question.sum % ANSWERS.size]
    end

    def result(id, payload)
      { jsonrpc: '2.0', id: id, result: payload }
    end

    def error_response(id, code, message)
      { jsonrpc: '2.0', id: id, error: { code: code, message: message } }
    end
  end
end

HeroOracle::Server.new.run if $PROGRAM_NAME == __FILE__
