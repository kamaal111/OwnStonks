//
//  UserSettings.swift
//
//
//  Created by Kamaal M Farah on 13/12/2023.
//

import Foundation
import Observation
import KamaalSettings

@Observable
public final class UserSettings {
    public init() { }

    var configuration: SettingsConfiguration {
        SettingsConfiguration()
    }
}
