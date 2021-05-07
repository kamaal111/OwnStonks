#!/bin/sh

#  pre_compile.sh
#  OwnStonks
#
#  Created by Kamaal Farah on 04/05/2021.
#  Copyright © 2021 Kamaal Farah. All rights reserved.
#

. ~/.zshrc
sh Scripts/generate_locales/run.sh

if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
