set export

PROJECT := "OwnStonks.xcodeproj"
SCHEME := "OwnStonks"

default:
    just --list

test-ios destination:
    #!/bin/zsh

    just test $SCHEME "{{ destination }}"

format:
    swiftformat .

bootstrap: brew-install-bundle install-node-modules

assert-has-no-diffs:
    #!/bin/zsh

    DIFFS=$(git diff --name-only origin/main | sed '/^$/d' | awk '{print NR}'| sort -nr | sed -n '1p')
    just assert-empty "$DIFFS"

[private]
test scheme destination:
    #!/bin/zsh

    CONFIGURATION="Debug"

    xctools test --configuration $CONFIGURATION --scheme "{{ scheme }}" \
        --destination "{{ destination }}" --project $PROJECT

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
