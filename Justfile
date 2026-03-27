# Claude Code Hero

# Run all tests
test:
    ruby -Iscripts/lib -Iscripts/test -e 'Dir["scripts/test/*_test.rb"].each { |f| require File.expand_path(f) }'

# Run a specific test file (e.g., just test-level level_1)
test-level name:
    ruby -Iscripts/lib -Iscripts/test -e 'require File.expand_path("scripts/test/{{name}}_test.rb")'

# Lint all Ruby files
lint:
    rubocop scripts/

# Lint and auto-fix
lint-fix:
    rubocop scripts/ -A

# Verify all levels
verify:
    ruby scripts/cli.rb verify

# Verify a specific level
verify-level n:
    ruby scripts/cli.rb verify {{n}}

# Show quest metadata
levels:
    ruby scripts/cli.rb levels

# Show player progress
status:
    ruby scripts/cli.rb status

# Dry-run cleanup
clean-dry:
    ruby scripts/cli.rb clean --dry-run

# Clean all hero artifacts and reset progress
clean:
    ruby scripts/cli.rb clean

# Run tests + lint
check: test lint

# Launch the plugin locally
play:
    claude --plugin-dir . --agent heroguide
