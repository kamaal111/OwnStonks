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
        VStack {
            HStack {
                Text("Version")
                    .font(.headline)
                Spacer()
                Text(versionString)
            }
        }
        .navigationTitle(Text(localized: .SETTINGS))
        .padding(.all, size: .medium)
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
