//
//  ModifyTransactionSheet.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import AppUI
import SwiftUI
import KamaalUI

enum ModifyTransactionSheetContext {
    case new
}

struct ModifyTransactionSheet: View {
    @Binding var isShown: Bool

    let context: ModifyTransactionSheetContext
    let onDone: () -> Void

    var body: some View {
        KSheetStack(
            title: title,
            leadingNavigationButton: { navigationButton(label: "Close", action: { isShown = false }) },
            trailingNavigationButton: { navigationButton(label: "Done", action: onDone) }
        ) {
            Text("Hello")
        }
        .padding(.vertical, .medium)
    }

    private var title: String {
        switch context {
        case .new: NSLocalizedString("Add Transaction", bundle: .module, comment: "")
        }
    }

    private func navigationButton(label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label, bundle: .module)
                .bold()
                .foregroundStyle(.tint)
        }
    }
}

#Preview {
    ModifyTransactionSheet(isShown: .constant(true), context: .new, onDone: { })
}
