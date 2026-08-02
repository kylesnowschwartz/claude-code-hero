# frozen_string_literal: true

module Hero
  class Level12 < Level
    number   12
    name     'The Warband'
    feature  'Dynamic workflows'
    artifact '.claude/workflows/hero-*.js'

    WORKFLOW_DIR = '.claude/workflows'
    FAN_OUT = /\b(?:pipeline|parallel)\s*\(/

    verify do
      dir_exists WORKFLOW_DIR
      path = hero_workflow
      source = File.read(path)

      check_meta(source, path)
      check_agents(source, path)
      check_fan_out(source, path)
    end

    clean do
      Dir.glob(File.join(expand(WORKFLOW_DIR), 'hero-*.js')).each do |path|
        remove_file path
      end
      remove_dir_if_empty WORKFLOW_DIR
    end

    private

    def hero_workflow
      found = Dir.glob(File.join(expand(WORKFLOW_DIR), 'hero-*.js')).min
      raise CheckFailed, "No hero-*.js workflow in #{WORKFLOW_DIR}" unless found

      found
    end

    def relative(path)
      path.sub("#{Hero::PROJECT_ROOT}/", '')
    end

    # Every workflow script must open with a literal meta block -- the runtime
    # reads it before running anything, so a computed one fails to load.
    def check_meta(source, path)
      unless source.match?(/export\s+const\s+meta\s*=/)
        raise CheckFailed, "#{relative(path)} has no `export const meta = {...}` block"
      end

      name = source[/name\s*:\s*['"]([^'"]+)['"]/, 1]
      raise CheckFailed, "#{relative(path)} has no `name` in its meta block" unless name
      return if name.match?(/hero/i)

      raise CheckFailed, "The workflow's meta name is #{name.inspect} -- it needs to contain \"hero\""
    end

    def check_agents(source, path)
      count = source.scan(/\bagent\s*\(/).size
      if count.zero?
        raise CheckFailed,
              "#{relative(path)} never calls agent() -- a workflow with no agents does nothing"
      end

      return if count <= 3

      raise CheckFailed,
            "#{relative(path)} calls agent() #{count} times. Keep a first warband to three or fewer -- " \
            'every agent is a real model call.'
    end

    def check_fan_out(source, path)
      return if source.match?(FAN_OUT)

      raise CheckFailed,
            "#{relative(path)} calls agent() but never pipeline() or parallel(). " \
            'Running agents one at a time is just a longer conversation.'
    end
  end
end
