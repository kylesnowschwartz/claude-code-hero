# frozen_string_literal: true

module Hero
  class Level0 < Level
    number   0
    name     'The Threshold'
    feature  'Basic interaction'
    artifact '.claude/hero-journal.md'

    verify do
      file_exists artifact
      min_content_lines artifact, min: 5
    end

    clean do
      remove_file artifact
    end
  end
end
