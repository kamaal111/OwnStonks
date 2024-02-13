#!/bin/zsh

if which brew > /dev/null
then
else
    echo "Installing brew"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

if which just > /dev/null
then
else
    echo "Install just"
    brew install just
fi

just bootstrap || exit 1
