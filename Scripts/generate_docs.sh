#!/bin/sh

#  generate_docs.sh
#  OwnStonks
#
#  Created by Kamaal M Farah on 05/05/2021.
#  Copyright © 2021 Kamaal Farah. All rights reserved.

jazzy --build-tool-arguments -scheme,"OwnStonks (macOS)" --min-acl internal
cd Packages/StonksUI
jazzy
