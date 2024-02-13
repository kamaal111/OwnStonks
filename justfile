set export

APPLE_PLATFORMS_PATH := "apps/ApplePlatforms"

# List available commands
default:
    #!/bin/zsh

    just --list --unsorted --list-heading $'Available commands\n'

# Format code
format: format-swift-code

# Format staged code
format-staged: format-staged-swift-code

# Test app on Apple platforms 
test-apple-platforms:
    just $APPLE_PLATFORMS_PATH/test-all

# Test app on iOS
test-ios:
    just $APPLE_PLATFORMS_PATH/test-ios

# Test app on macOS
test-macos:
    just $APPLE_PLATFORMS_PATH/test-macos

# Deploy app for Apple platforms
deploy-apple-platforms:
    just $APPLE_PLATFORMS_PATH/deploy-all

# Deploy iOS app
deploy-ios:
    just $APPLE_PLATFORMS_PATH/deploy-ios

# Deploy macOS app
deploy-macos:
    just $APPLE_PLATFORMS_PATH/deploy-macos

bump-apple-platforms-version number:
    just $APPLE_PLATFORMS_PATH/bump-version {{number}}

# Bootstrap the essential tools to develop in this codebase
bootstrap: bootstrap-for-apple-platforms

# Bootstrap the essential tools to develop for Apple platforms
bootstrap-for-apple-platforms: shared-bootstrap-script
    just $APPLE_PLATFORMS_PATH/bootstrap

# Install node modules
install-node-modules:
    bun install

# Install Bun
install-bun:
    #!/bin/bash

    curl -fsSL https://bun.sh/install | bash

# Assert there are no changes staged
assert-has-no-diffs:
    #!/bin/zsh

    DIFFS=$(git diff --name-only origin/main | sed '/^$/d' | awk '{print NR}'| sort -nr | sed -n '1p')
    just assert-empty "$DIFFS"

[private]
format-swift-code:
    swiftformat .

[private]
format-staged-swift-code:
    bun run format-staged

[private]
shared-bootstrap-script: install-bun install-node-modules

[private]
assert-empty value:
    python3 scripts/asserts/empty.py "{{ value }}"
