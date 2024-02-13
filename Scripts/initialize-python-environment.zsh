#!/bin/zsh

if [ ! -d .venv ]
then
    python3 -m venv .venv
fi
. .venv/bin/activate
pip install --upgrade pip
pip install poetry
poetry install -n --no-root
