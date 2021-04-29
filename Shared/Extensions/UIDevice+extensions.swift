//
//  UIDevice+extensions.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import UIKit

extension UIDevice {
    var isIpad: Bool {
        self.userInterfaceIdiom == .pad
    }
}
