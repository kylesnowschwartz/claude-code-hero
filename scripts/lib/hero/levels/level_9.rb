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

    bonus 'publishing to a marketplace' do
      _manifest, plugin_dir = find_hero_plugin
      check_marketplace(plugin_dir)
    end

    clean do
      remove_hero_plugins
    end

    private

    # A marketplace is what makes a plugin installable by someone else, so the
    # entry has to actually point at the plugin the player just built.
    def check_marketplace(plugin_dir)
      path = File.join(plugin_dir, '.claude-plugin', 'marketplace.json')
      raise CheckFailed, "No marketplace.json at #{path}" unless File.file?(path)

      data = parse_json(path)
      raise CheckFailed, 'marketplace.json needs a "name"' unless data['name'].is_a?(String)
      raise CheckFailed, 'marketplace.json needs an "owner" object' unless data['owner'].is_a?(Hash)

      entries = data['plugins']
      raise CheckFailed, 'marketplace.json needs a non-empty "plugins" array' unless entries.is_a?(Array) &&
                                                                                     !entries.empty?

      check_marketplace_entry(entries)
    end

    def check_marketplace_entry(entries)
      listed = entries.find { |e| e.is_a?(Hash) && e['name'].to_s.match?(/hero/i) && e['source'] }
      return if listed

      raise CheckFailed,
            'No entry in "plugins" with a hero name and a "source". ' \
            "Found: #{entries.map { |e| e.is_a?(Hash) ? e['name'] : e }.inspect}"
    end

    def parse_json(path)
      JSON.parse(File.read(path))
    rescue JSON::ParserError => e
      raise CheckFailed, "marketplace.json is not valid JSON: #{e.message}"
    end

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
            "Plugin found but has no component directories (#{COMPONENT_DIRS.map { |d| "#{d}/" }.join(', ')})"
    end

    def remove_hero_plugins
      CANDIDATES.each do |candidate|
        manifest = File.join(Hero::PROJECT_ROOT, candidate, '.claude-plugin', 'plugin.json')
        next unless File.file?(manifest)
        next unless File.read(manifest).match?(/hero/i)

        unless dry_run?
          plugin_meta_dir = File.dirname(manifest)
          File.delete(manifest)
          FileUtils.rm_f(File.join(plugin_meta_dir, 'marketplace.json'))
          Dir.rmdir(plugin_meta_dir) if (Dir.entries(plugin_meta_dir) - %w[. ..]).empty?
        end
        record_action("remove plugin #{candidate}")
      end
    end
  end
end
