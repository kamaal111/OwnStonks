//
//  UserSettingsScreen.swift
//
//
//  Created by Kamaal M Farah on 13/12/2023.
//

import SwiftUI
import KamaalSettings

public struct UserSettingsScreen: View {
    @Environment(UserSettings.self) private var userSettings

    public init() { }

    public var body: some View {
        SettingsScreen(configuration: userSettings.configuration)
    }
}
