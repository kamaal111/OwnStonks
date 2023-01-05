//
//  AppSettingsScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 04/01/2023.
//

import SwiftUI
import SettingsUI

struct AppSettingsScreen: View {
    @EnvironmentObject private var userData: UserData

    var body: some View {
        SettingsScreen(configuration: userData.settingsConfiguration)
            .onSettingsPreferenceChange({ preference in userData.handlePreferenceChange(preference) })
            .onAppear(perform: handleOnAppear)
    }

    private func handleOnAppear() {
        Task {
            await userData.loadAcknowledgements()
        }
    }
}

struct AppSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsScreen()
    }
}
