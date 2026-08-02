# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class Level11Test < HeroTestCase
  CONFIG = '.mcp.json'
  REAL_SERVER = File.expand_path('../hero-oracle-server.rb', __dir__)

  def server_path
    File.join(@tmpdir, 'scripts', 'hero-oracle-server.rb')
  end

  def setup
    super
    FileUtils.mkdir_p(File.dirname(server_path))
    FileUtils.cp(REAL_SERVER, server_path)
  end

  def write_config(data)
    write_file(CONFIG, JSON.pretty_generate(data))
  end

  def valid_config(name: 'hero-oracle', args: nil)
    { 'mcpServers' => { name => { 'command' => 'ruby', 'args' => args || [server_path] } } }
  end

  # --- Verification ---

  def test_verify_passes_with_a_working_server
    write_config(valid_config)
    passed, msg = Hero::Level11.new.verify
    assert passed, msg
  end

  def test_verify_accepts_servers_at_the_top_level
    write_config(valid_config['mcpServers'])
    passed, msg = Hero::Level11.new.verify
    assert passed, msg
  end

  def test_verify_fails_without_config
    passed, msg = Hero::Level11.new.verify
    refute passed
    assert_match(/Missing file/, msg)
  end

  def test_verify_fails_on_invalid_json
    write_file(CONFIG, '{ not json')
    passed, msg = Hero::Level11.new.verify
    refute passed
    assert_match(/not valid JSON/, msg)
  end

  def test_verify_fails_without_a_hero_named_server
    write_config({ 'mcpServers' => { 'oracle' => { 'command' => 'ruby', 'args' => [server_path] } } })
    passed, msg = Hero::Level11.new.verify

    refute passed
    assert_match(/contains "hero"/, msg)
  end

  def test_verify_fails_without_a_command
    write_config({ 'mcpServers' => { 'hero-oracle' => { 'args' => [server_path] } } })
    passed, msg = Hero::Level11.new.verify

    refute passed
    assert_match(/needs a "command"/, msg)
  end

  def test_verify_fails_when_the_script_is_missing
    write_config(valid_config(args: [File.join(@tmpdir, 'scripts', 'nope.rb')]))
    passed, msg = Hero::Level11.new.verify

    refute passed
    assert_match(/does not exist/, msg)
  end

  # Claude Code injects neither of these into .mcp.json, so a config using them
  # fails to connect. Verification has to fail with it, not paper over it.
  def test_verify_rejects_the_project_dir_variable
    write_config(valid_config(args: ['${CLAUDE_PROJECT_DIR}/scripts/hero-oracle-server.rb']))
    passed, msg = Hero::Level11.new.verify

    refute passed
    assert_match(/\$\{CLAUDE_PROJECT_DIR\}/, msg)
    assert_match(/Missing environment variables/, msg)
  end

  def test_verify_rejects_the_plugin_root_variable
    write_config(valid_config(args: ['${CLAUDE_PLUGIN_ROOT}/scripts/hero-oracle-server.rb']))
    passed, msg = Hero::Level11.new.verify

    refute passed
    assert_match(/\$\{CLAUDE_PLUGIN_ROOT\}/, msg)
  end

  def test_verify_accepts_a_relative_path
    write_config(valid_config(args: ['scripts/hero-oracle-server.rb']))
    passed, msg = Hero::Level11.new.verify

    assert passed, msg
  end

  def test_verify_expands_a_variable_that_is_set_in_the_shell
    ENV['HERO_TEST_ROOT'] = @tmpdir
    write_config(valid_config(args: ['${HERO_TEST_ROOT}/scripts/hero-oracle-server.rb']))
    passed, msg = Hero::Level11.new.verify

    assert passed, msg
  ensure
    ENV.delete('HERO_TEST_ROOT')
  end

  # Config alone must not be enough -- this is the point of the level.
  def test_verify_fails_when_the_server_is_wired_but_broken
    File.write(server_path, "#!/usr/bin/env ruby\nexit 1\n")
    write_config(valid_config)
    passed, msg = Hero::Level11.new.verify

    refute passed
    assert_match(/no JSON-RPC result|exited with an error/, msg)
  end

  def test_verify_fails_when_the_server_lists_no_oracle_tool
    File.write(server_path, <<~RUBY)
      #!/usr/bin/env ruby
      $stdin.each_line { puts '{"jsonrpc":"2.0","id":1,"result":{"tools":[]}}' }
    RUBY
    write_config(valid_config)
    passed, msg = Hero::Level11.new.verify

    refute passed
    assert_match(/listed no consult_oracle tool/, msg)
  end

  # --- Cleanup ---

  def test_clean_removes_the_config_when_only_hero_remains
    write_config(valid_config)
    Hero::Level11.new.clean

    refute File.exist?(File.join(@tmpdir, CONFIG))
  end

  def test_clean_preserves_other_servers
    config = valid_config
    config['mcpServers']['other'] = { 'command' => 'true' }
    write_config(config)
    Hero::Level11.new.clean

    remaining = read_json(CONFIG)['mcpServers']
    assert_equal ['other'], remaining.keys
  end

  def test_clean_dry_run_preserves_everything
    write_config(valid_config)
    Hero::Level11.new(dry_run: true).clean

    assert File.exist?(File.join(@tmpdir, CONFIG))
  end
end
