# frozen_string_literal: true

module Hero
  class Level1 < Level
    number   1
    name     'The Map Room'
    feature  '.claude/ exploration'
    artifact '.claude/hero-map.md'

    verify do
      file_exists artifact
      heading_count artifact, min: 3
    end

    clean do
      remove_file artifact
    end
  end
end
