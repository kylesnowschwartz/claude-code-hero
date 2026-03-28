# frozen_string_literal: true

module Hero
  class Level9 < Level
    number   9
    name     "The Artificer's Workshop"
    feature  'Plugins (capstone)'
    artifact 'plugin.json'

    CANDIDATES = %w[hero-toolkit hero-plugin claude-code-hero-plugin].freeze
    COMPONENT_DIRS = %w[commands skills agents hooks rules].freeze

    verify do
      manifest, plugin_dir = find_hero_plugin
      grep_match manifest, '"name"'
      grep_match manifest, 'hero', case_insensitive: true
      check_has_components(plugin_dir)
    end

    clean do
      remove_hero_plugins
    end

    private

    def find_hero_plugin
      CANDIDATES.each do |candidate|
        manifest = File.join(Hero::PROJECT_ROOT, candidate, '.claude-plugin', 'plugin.json')
        next unless File.file?(manifest)

        plugin_dir = File.dirname(manifest, 2)
        return [manifest, plugin_dir]
      end
      raise CheckFailed, "No plugin with 'hero' in name found"
    end

    def check_has_components(plugin_dir)
      has_component = COMPONENT_DIRS.any? { |d| File.directory?(File.join(plugin_dir, d)) }
      return if has_component

      raise CheckFailed,
            'Plugin found but has no component directories (commands/, skills/, agents/, or hooks/)'
    end

    def remove_hero_plugins
      CANDIDATES.each do |candidate|
        manifest = File.join(Hero::PROJECT_ROOT, candidate, '.claude-plugin', 'plugin.json')
        next unless File.file?(manifest)
        next unless File.read(manifest).match?(/hero/i)

        unless dry_run?
          File.delete(manifest)
          plugin_meta_dir = File.dirname(manifest)
          Dir.rmdir(plugin_meta_dir) if (Dir.entries(plugin_meta_dir) - %w[. ..]).empty?
        end
        record_action("remove plugin #{candidate}")
      end
    end
  end
end
