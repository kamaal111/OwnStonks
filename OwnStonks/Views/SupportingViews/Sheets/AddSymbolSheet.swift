//
//  AddSymbolSheet.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 29/12/2022.
//

import SwiftUI
import SalmonUI
import OSLocales

struct AddSymbolSheet: View {
    var body: some View {
        KSheetStack(
            title: OSLocales.getText(.ADD_SYMBOL),
            leadingNavigationButton: { closeButton },
            trailingNavigationButton: { doneButton }) {
                Text("Symbol")
            }
            .frame(minWidth: 200, minHeight: 200)
    }

    private var closeButton: some View {
        OSButton(action: onClose) {
            OSText(localized: .CLOSE)
                .foregroundColor(.accentColor)
        }
    }

    private var doneButton: some View {
        OSButton(action: onDone) {
            OSText(localized: .DONE)
                .foregroundColor(.accentColor)
        }
    }

    private func onClose() { }

    private func onDone() { }
}

struct AddSymbolSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddSymbolSheet()
    }
}
