//
//  UserSettingsEnvironmentModifier.swift
//
//
//  Created by Kamaal M Farah on 13/12/2023.
//

import SwiftUI

extension View {
    public func userSettingsEnvironment(userSettings: UserSettings) -> some View {
        modifier(UserSettingsEnvironmentModifier(userSettings: userSettings))
    }
}

private struct UserSettingsEnvironmentModifier: ViewModifier {
    @State var userSettings: UserSettings

    func body(content: Content) -> some View {
        content
            .environment(userSettings)
    }
}
