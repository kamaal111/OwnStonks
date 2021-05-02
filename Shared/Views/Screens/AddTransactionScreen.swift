//
//  AddTransactionScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/05/2021.
//

import SwiftUI
import StonksUI

struct AddTransactionScreen: View {
    @State private var investment = ""
    @State private var costs = 0.0
    @State private var shares = 0.0

    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text("Add Transaction"), displayMode: .inline)
        #else
        view()
            .toolbar(content: {
                Button(action: { }) {
                    Text("Save")
                }
            })
            .navigationTitle(Text("Add Transaction"))
        #endif
    }

    private func view() -> some View {
        VStack {
            FloatingTextField(text: $investment, title: "Investment")
            EnforcedFloatingDecimalField(value: $costs, title: "Costs")
            EnforcedFloatingDecimalField(value: $shares, title: "Shares")
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
    }
}

struct AddTransactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionScreen()
    }
}
