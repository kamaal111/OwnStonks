//
//  AddTransactionScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/05/2021.
//

import SwiftUI

struct AddTransactionScreen: View {
    @State private var investment = ""
    @State private var costs = ""

    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text("Add Transaction"), displayMode: .inline)
        #else
        view()
            .toolbar(content: {
                Button(action: { }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
            })
            .navigationBarTitle(Text("Add Transaction"), displayMode: .inline)
        #endif
    }

    private func view() -> some View {
        VStack {
            FloatingTextField(text: $investment, title: "Investment")
            FloatingTextField(text: $costs, title: "Costs", textFieldType: .decimals)
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
