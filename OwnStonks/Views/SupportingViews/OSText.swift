//
//  OSText.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 29/12/2022.
//

import SwiftUI
import OSLocales

func OSText(_ content: String) -> Text {
    Text(content)
}

func OSText(localized key: OSLocales.Keys) -> Text {
    OSText(OSLocales.getText(key))
}

struct OSText_Previews: PreviewProvider {
    static var previews: some View {
        OSText("Text")
    }
}
