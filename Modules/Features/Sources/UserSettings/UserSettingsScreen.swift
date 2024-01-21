//
//  UserSettingsScreen.swift
//
//
//  Created by Kamaal M Farah on 13/12/2023.
//

import SwiftUI
import KamaalSettings

/// Main ``UserSettings`` screen.
public struct UserSettingsScreen: View {
    @Environment(UserSettings.self) private var userSettings

    /// Initializer of ``UserSettingsScreen``.
    public init() { }

    public var body: some View {
        SettingsScreen(configuration: userSettings.configuration)
            .onSettingsPreferenceChange { preference in userSettings.onPreferenceChange(preference) }
            .onFeatureChange { feature in userSettings.onFeaturesChange(feature) }
    }
}
