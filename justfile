set export
set dotenv-load

WORKSPACE := "OwnStonks.xcworkspace"
SCHEME := "OwnStonks"
APP_NAME := "$SCHEME"

default:
    just --list

format:
    swiftformat .

generate: make-secrets make-acknowledgments

bootstrap: brew-install-bundle install-node-modules init-python-environment install-gems generate

deploy-all: deploy-macos deploy-ios

deploy-macos: archive-macos upload-macos

deploy-ios: archive-ios upload-ios

test-all:
    just test "platform=iOS Simulator,name=iPhone 15 Pro Max"
    just test "platform=macOS"

assert-has-no-diffs:
    #!/bin/zsh

    DIFFS=$(git diff --name-only origin/main | sed '/^$/d' | awk '{print NR}'| sort -nr | sed -n '1p')
    just assert-empty "$DIFFS"

make-acknowledgments:
    #!/bin/zsh

    xctools acknowledgments --scheme $SCHEME --output Modules/Features/Sources/UserSettings/Internals/Resources

make-secrets:
    #!/bin/zsh

    . .venv/bin/activate

    python3 Scripts/make_secrets.py --output "Modules/Features/Sources/UserSettings/Internals/Resources/Secrets.json" \
        --github_token ${GITHUB_TOKEN:-""}
    python3 Scripts/make_secrets.py --output "Modules/Features/Sources/ValutaConversion/Internals/Resources/Secrets.json" \
        --forex_api_url ${FOREX_API_URL:-""}

test destination:
    #!/bin/zsh

    CONFIGURATION="Debug"

    set -o pipefail && xctools test --configuration $CONFIGURATION --scheme $SCHEME \
        --destination "{{ destination }}" --workspace $WORKSPACE | xcpretty

upload-macos:
    #!/bin/zsh

    just upload-app macos $APP_NAME.pkg

upload-ios:
    #!/bin/zsh

    just upload-app ios $APP_NAME.ipa

archive-macos:
    #!/bin/zsh

    ARCHIVE_PATH="$APP_NAME.xcarchive"
    rm -rf $ARCHIVE_PATH

    just archive "macosx" "platform=macOS" "$ARCHIVE_PATH"
    just export-archive "ExportOptions/MacOS.plist" "$ARCHIVE_PATH"

archive-ios:
    #!/bin/zsh

    ARCHIVE_PATH="$APP_NAME.xcarchive"
    rm -rf $ARCHIVE_PATH

    just archive "iphoneos" "generic/platform=iOS" "$ARCHIVE_PATH"
    just export-archive "ExportOptions/IOS.plist" "$ARCHIVE_PATH"

bump-version number:
    xctools bump-version --build-number {{number}}

[private]
export-archive export-options archive:
    #!/bin/zsh

    xctools export-archive --archive-path "{{ archive }}" --export-options "{{ export-options }}"

[private]
archive sdk destination archive-path:
    #!/bin/zsh

    CONFIGURATION="Release"

    set -o pipefail && xctools archive --configuration $CONFIGURATION --scheme $SCHEME \
        --destination "{{ destination }}" --sdk {{ sdk }} --archive-path "{{ archive-path }}" \
        --workspace $WORKSPACE | xcpretty

[private]
upload-app target binary-name:
    xctools upload --file {{ binary-name }} --target {{ target }} --username kamaal.f1@gmail.com \
        --password $APP_STORE_CONNECT_PASSWORD

[private]
install-gems:
    #!/bin/zsh

    bundle install

[private]
init-python-environment:
    #!/bin/zsh

    if [ ! -d .venv ]
    then
        python3 -m venv .venv
    fi
    . .venv/bin/activate
    pip install poetry
    poetry install -n

[private]
brew-install-bundle:
    #!/bin/zsh

    brew update
    brew tap homebrew/bundle
    brew bundle

[private]
install-node-modules:
    bun install

[private]
assert-empty value:
    python3 Scripts/asserts/empty.py "{{ value }}"
