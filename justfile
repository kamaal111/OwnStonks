set export

APPLE_PLATFORMS_PATH := "apps/ApplePlatforms"
API_PATH := "apps/API"
VIRTUAL_ENVIRONMENT := ".venv"

# List available commands
default:
    just --list --unsorted --list-heading $'Available commands\n'

# Format code
format: format-swift format-python

# Format staged code
format-staged: format-staged-swift-code format-python

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

# Deploy API
deploy-api-image tag:
    just $API_PATH/deploy-image {{tag}}

# Build and run API
build-run-api:
    just $API_PATH/build-run

# Run API in DEV mode
run-dev-api:
    just $API_PATH/run-dev

# Build API
build-api:
    just $API_PATH/build

# Trust Swift macros
trust-swift-macro:
    just $APPLE_PLATFORMS_PATH/trust-swift-macro

# Bump Apple platforms app version
bump-apple-platforms-version number:
    just $APPLE_PLATFORMS_PATH/bump-version {{number}}

# Bootstrap the essential tools to develop in this codebase
bootstrap: bootstrap-apple-platforms bootstrap-api

# Bootstrap the essential tools to develop for Apple platforms
bootstrap-apple-platforms: shared-bootstrap-script
    just $APPLE_PLATFORMS_PATH/bootstrap

# Bootstrap the essential tools to develop the API
bootstrap-api:
    just $API_PATH/bootstrap

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

# Initialize Python environment
init-python-environment:
    zsh scripts/initialize-python-environment.zsh

# Format Python code
format-python:
    #!/bin/zsh

    . $VIRTUAL_ENVIRONMENT/bin/activate

    ruff check --fix

# Format Swift code
format-swift:
    swiftformat .

[private]
format-staged-swift-code:
    npx git-format-staged --formatter "swiftformat stdin --stdinpath '{}'" "*.swift"

[private]
shared-bootstrap-script: install-bun install-node-modules init-python-environment

[private]
assert-empty value:
    python3 scripts/asserts/empty.py "{{ value }}"
