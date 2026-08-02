# frozen_string_literal: true

module Hero
  # The music preference lives in the player's home directory, not in the
  # progress file, so that resetting or cleaning a playthrough cannot turn
  # music back on. The flag file's presence means off.
  #
  # play-music.sh reads the same path. Keep the two in step -- music_test.rb
  # asserts they agree.
  module Music
    FLAG_NAME = 'claude-code-hero-music-off'

    def self.flag_path
      File.join(Dir.home, '.claude', FLAG_NAME)
    end

    def self.enabled?
      !File.exist?(flag_path)
    end

    def self.disable!
      FileUtils.mkdir_p(File.dirname(flag_path))
      File.write(flag_path, "Music is off. Delete this file or run: ruby scripts/cli.rb music on\n")
      nil
    end

    def self.enable!
      FileUtils.rm_f(flag_path)
      nil
    end

    def self.toggle!
      enabled? ? disable! : enable!
    end
  end
end
