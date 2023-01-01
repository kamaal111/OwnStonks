//
//  InvisibleFill.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import SwiftUI
import SalmonUI

extension View {
    func invisibleFill() -> some View {
        ktakeWidthEagerly()
        #if os(macOS)
            .background(Color(nsColor: .separatorColor).opacity(0.01))
        #else
            .background(Color(uiColor: .separator).opacity(0.01))
        #endif
    }
}
