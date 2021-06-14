//
//  SettingsScene.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 14/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI

struct SettingsScene: View {
    var body: some View {
        #warning("Work on settings")
        VStack {
            HStack {
                Text("Version")
                    .font(.headline)
                Spacer()
                Text(versionString)
            }
        }
        /// - TODO: Localize this
        .navigationTitle(Text("Settings"))
        .padding(.all, .medium)
        .frame(minWidth: 200, maxWidth: 200, minHeight: 200, alignment: .topLeading)
    }

    var versionString: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

struct SettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScene()
    }
}
