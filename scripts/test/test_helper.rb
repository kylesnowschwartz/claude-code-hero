# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'json'

# Override HOME and PROJECT_ROOT before loading hero so all path expansion uses tmpdir
class HeroTestCase < Minitest::Test
  def setup
    @original_home = Dir.home
    @tmpdir = Dir.mktmpdir('hero-test-')
    ENV['HOME'] = @tmpdir
    FileUtils.mkdir_p(File.join(@tmpdir, '.claude'))

    # Override PROJECT_ROOT for .claude/ path resolution
    @original_project_root = Hero::PROJECT_ROOT
    Hero.send(:remove_const, :PROJECT_ROOT)
    Hero.const_set(:PROJECT_ROOT, @tmpdir)

    $LOAD_PATH.unshift(File.join(__dir__, '..', 'lib')) unless $LOAD_PATH.include?(File.join(__dir__, '..', 'lib'))
  end

  def teardown
    ENV['HOME'] = @original_home
    Hero.send(:remove_const, :PROJECT_ROOT)
    Hero.const_set(:PROJECT_ROOT, @original_project_root)
    FileUtils.rm_rf(@tmpdir) if @tmpdir && File.directory?(@tmpdir)
  end

  def write_file(relative_to_root, content)
    path = File.join(@tmpdir, relative_to_root)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  def write_settings(data)
    write_file('.claude/settings.json', JSON.pretty_generate(data))
  end

  def write_progress(data)
    write_file('.claude/claude-code-hero.json', JSON.pretty_generate(data))
  end

  def read_json(relative_to_root)
    JSON.parse(File.read(File.join(@tmpdir, relative_to_root)))
  end
end
