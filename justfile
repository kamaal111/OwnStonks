set export
set dotenv-load

WORKSPACE := "OwnStonks.xcworkspace"
SCHEME := "OwnStonks"

default:
    just --list

format:
    swiftformat .

bootstrap: brew-install-bundle install-node-modules init-python-environment make-secrets

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

test scheme destination:
    #!/bin/zsh

    CONFIGURATION="Debug"

    xctools test --configuration $CONFIGURATION --scheme "{{ scheme }}" \
        --destination "{{ destination }}" --workspace $WORKSPACE | xcpretty && exit ${PIPESTATUS[0]}

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
