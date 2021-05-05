//
//  UIDevice+extensions.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import UIKit

extension UIDevice {
    var isIpad: Bool {
        self.userInterfaceIdiom == .pad
    }
}
