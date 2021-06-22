//
//  Notification+extionsions.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 22/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let deviceDidShake = Self(rawValue: constructIdentifier(name: "deviceDidShake"))
}

private func constructIdentifier(name: String) -> String {
    "Notification.\(Constants.appBundleIdentifier).\(name)"
}
