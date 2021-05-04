#!/bin/sh

#  pre_compile.sh
#  OwnStonks
#
#  Created by Kamaal Farah on 04/05/2021.
#  

if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
