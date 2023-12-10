//
//  AddFirstTransactionButton.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import KamaalUI

struct AddFirstTransactionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Add your first transaction", bundle: .module)
                .foregroundColor(.accentColor)
                .kInvisibleFill()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddFirstTransactionButton(action: { })
}
