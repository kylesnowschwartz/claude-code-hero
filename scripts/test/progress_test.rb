# frozen_string_literal: true

require_relative 'test_helper'
require 'hero'

class ProgressTest < HeroTestCase
  def progress_path
    File.join(@tmpdir, '.claude', 'claude-code-hero.json')
  end

  def test_initializes_with_defaults
    p = Hero::Progress.new(path: progress_path)
    assert_equal 1, p.data['current_level']
    assert_empty p.data['completed']
  end

  def test_reads_existing_progress
    write_progress({ 'current_level' => 3,
                     'completed' => { '1' => '2026-01-01T00:00:00Z', '2' => '2026-01-02T00:00:00Z' } })
    p = Hero::Progress.new(path: progress_path)
    assert_equal 3, p.data['current_level']
    assert_equal 2, p.data['completed'].size
  end

  def test_status_new
    p = Hero::Progress.new(path: progress_path)
    assert_equal 'new', p.status
  end

  def test_status_in_progress
    write_progress({ 'current_level' => 3, 'completed' => { '1' => '2026-01-01T00:00:00Z' } })
    p = Hero::Progress.new(path: progress_path)
    assert_equal 'in_progress', p.status
  end

  def test_status_complete
    write_progress({ 'current_level' => 10, 'completed' => {} })
    p = Hero::Progress.new(path: progress_path)
    assert_equal 'complete', p.status
  end

  def test_advance
    p = Hero::Progress.new(path: progress_path)
    p.advance!(1)
    assert_equal 2, p.data['current_level']
    assert p.data['completed'].key?('1')
    assert_match(/\d{4}-\d{2}-\d{2}T/, p.data['completed']['1'])
  end

  def test_reset
    write_progress({ 'current_level' => 5, 'completed' => { '1' => 'x' } })
    p = Hero::Progress.new(path: progress_path)
    p.reset!
    assert_equal 1, p.data['current_level']
    assert_empty p.data['completed']
  end

  def test_highest_passing
    write_progress({ 'current_level' => 5, 'completed' => { '1' => 'x', '3' => 'x', '4' => 'x' } })
    p = Hero::Progress.new(path: progress_path)
    assert_equal 4, p.highest_passing
  end

  def test_to_h_shape
    p = Hero::Progress.new(path: progress_path)
    h = p.to_h
    assert_includes h.keys, :current_level
    assert_includes h.keys, :completed
    assert_includes h.keys, :highest_passing
    assert_includes h.keys, :status
  end
end
