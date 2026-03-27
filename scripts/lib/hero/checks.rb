# frozen_string_literal: true

module Hero
  class CheckFailed < StandardError; end

  # Verification and cleanup primitives for level definitions.
  # Included by Hero::Level; methods execute in instance context.
  module Checks
    def expand(path)
      path.sub('~', Dir.home)
    end

    # --- Verification primitives ---

    def file_exists(path)
      full = expand(path)
      raise CheckFailed, "Missing file: #{path}" unless File.file?(full)
    end

    def dir_exists(path)
      full = expand(path)
      raise CheckFailed, "Missing directory: #{path}" unless File.directory?(full)
    end

    def heading_count(path, min:)
      full = expand(path)
      count = File.readlines(full).count { |l| l.match?(/^## /) }
      raise CheckFailed, "Expected >= #{min} ## headings in #{path}, found #{count}" unless count >= min
    end

    def grep_match(path, pattern, case_insensitive: false, expect_missing: false)
      full = expand(path)
      re = case_insensitive ? Regexp.new(pattern, Regexp::IGNORECASE) : Regexp.new(pattern)
      found = File.readlines(full).any? { |l| l.match?(re) }

      if expect_missing
        raise CheckFailed, "Pattern /#{pattern}/ should not be in #{path}" if found
      else
        raise CheckFailed, "Pattern /#{pattern}/ not found in #{path}" unless found
      end
    end

    def section_content_lines(path, heading:, min:)
      full = expand(path)
      lines = File.readlines(full)
      count = count_section_lines(lines, heading)

      return if count >= min

      raise CheckFailed, "Section '#{heading}' has #{count} content lines, expected >= #{min}"
    end

    def json_array_match(path, keys, pattern:)
      full = expand(path)
      data = JSON.parse(File.read(full))
      arr = dig_keys(data, keys)
      raise CheckFailed, "Key path #{keys.join('.')} not found in #{path}" unless arr.is_a?(Array)

      re = Regexp.new(pattern)
      return if arr.any? { |v| v.to_s.match?(re) }

      raise CheckFailed, "No element matching /#{pattern}/ in #{keys.join('.')} of #{path}"
    end

    def json_field_exists(path, keys)
      full = expand(path)
      data = JSON.parse(File.read(full))
      val = dig_keys(data, keys)
      return unless val.nil? || (val.respond_to?(:empty?) && val.empty?)

      raise CheckFailed, "Key path #{keys.join('.')} missing or empty in #{path}"
    end

    def find_file(name:, under:, path_contains: nil)
      full = expand(under)
      found = Dir.glob(File.join(full, '**', name))
      found = found.select { |f| f.include?(path_contains) } if path_contains
      raise CheckFailed, "File '#{name}' not found under #{under}" if found.empty?

      found.first
    end

    # --- Cleanup primitives ---

    def remove_file(path)
      full = expand(path)
      return unless File.exist?(full)

      File.delete(full) unless dry_run?
      record_action("remove #{path}")
    end

    def remove_dir_if_empty(path)
      full = expand(path)
      return unless File.directory?(full) && (Dir.entries(full) - %w[. ..]).empty?

      Dir.rmdir(full) unless dry_run?
      record_action("rmdir #{path}")
    end

    def remove_md_section(path, heading:)
      full = expand(path)
      return unless File.exist?(full)

      lines = File.readlines(full)
      start_idx = lines.index { |l| l.strip == heading }
      return unless start_idx

      end_idx = find_next_heading(lines, start_idx) || lines.size
      lines.slice!(start_idx...end_idx)
      lines.pop while lines.last&.strip&.empty?

      File.write(full, lines.join) unless dry_run?
      record_action("remove section '#{heading}' from #{path}")
    end

    def json_remove_matching(path, keys:, pattern:, cleanup_keys: [])
      full = expand(path)
      return unless File.exist?(full)

      data = JSON.parse(File.read(full))
      arr = dig_keys(data, keys)
      return unless arr.is_a?(Array)

      re = Regexp.new(pattern)
      before = arr.size
      arr.reject! { |entry| entry.to_s.match?(re) }
      return if arr.size == before

      prune_empty_containers(data, cleanup_keys)
      File.write(full, "#{JSON.pretty_generate(data)}\n") unless dry_run?
      record_action("remove matching entries from #{path}")
    end

    def reset_file_region(path, start_marker:, end_marker:, replacement:)
      full = expand(path)
      return unless File.exist?(full)

      lines = File.readlines(full)
      start_idx = lines.index { |l| l.include?(start_marker) }
      return unless start_idx

      end_idx = ((start_idx + 1)...lines.size).find { |i| lines[i].include?(end_marker) }
      return unless end_idx

      # Replace lines between markers (exclusive of markers themselves)
      lines[(start_idx + 1)...end_idx] = ["#{replacement}\n"]
      File.write(full, lines.join) unless dry_run?
      record_action("reset region in #{path}")
    end

    def json_remove_from_arrays(path, removals:, cleanup_paths: [])
      full = expand(path)
      return unless File.exist?(full)

      data = JSON.parse(File.read(full))
      changed = apply_removals(data, removals)
      prune_empty_containers(data, cleanup_paths)

      return unless changed

      File.write(full, "#{JSON.pretty_generate(data)}\n") unless dry_run?
      record_action("remove hero entries from #{path}")
    end

    private

    def count_section_lines(lines, heading)
      in_section = false
      count = 0

      lines.each do |line|
        if line.strip.start_with?('## ')
          break if in_section

          if line.strip == heading
            in_section = true
            next
          end
        elsif in_section && !line.strip.empty?
          count += 1
        end
      end

      raise CheckFailed, "Section '#{heading}' not found" unless in_section

      count
    end

    def find_next_heading(lines, start_idx)
      ((start_idx + 1)...lines.size).find { |i| lines[i].strip.start_with?('## ') }
    end

    def apply_removals(data, removals)
      changed = false
      removals.each do |keys, values|
        arr = dig_keys(data, keys)
        next unless arr.is_a?(Array)

        before = arr.size
        values.each { |v| arr.delete(v) }
        changed = true if arr.size != before
      end
      changed
    end

    def prune_empty_containers(data, paths)
      paths.each do |keys|
        parent_keys = keys[0..-2]
        key = keys.last
        parent = parent_keys.empty? ? data : dig_keys(data, parent_keys)
        next unless parent.is_a?(Hash)

        val = parent[key]
        parent.delete(key) if (val.is_a?(Array) && val.empty?) || (val.is_a?(Hash) && val.empty?)
      end
    end

    def dig_keys(data, keys)
      keys.reduce(data) { |d, k| d.is_a?(Hash) ? d[k] : nil }
    end

    def dry_run?
      @dry_run || false
    end

    def record_action(msg)
      @actions ||= []
      @actions << msg
    end
  end
end
