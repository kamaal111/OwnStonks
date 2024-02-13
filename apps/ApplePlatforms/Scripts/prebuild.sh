#!/bin/sh

#  prebuild.sh
#  OwnStonks
#
#  Created by Kamaal M Farah on 24/11/2023.
#  

if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
