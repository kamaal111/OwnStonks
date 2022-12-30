//
//  MoneyTextField.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import SwiftUI
import SalmonUI
import OSLocales

struct MoneyTextField: View {
    @Binding var currency: Currencies
    @Binding var value: Double

    @State private var stringValue = ""

    let title: String

    init(currency: Binding<Currencies>, value: Binding<Double>, title: String) {
        self._currency = currency
        self._value = value
        self.title = title
    }

    init(currency: Binding<Currencies>, value: Binding<Double>, localized: OSLocales.Keys) {
        self.init(currency: currency, value: value, title: OSLocales.getText(localized))
    }

    var body: some View {
        TitledView(title: title) {
            HStack {
                Picker("", selection: $currency) {
                    ForEach(Currencies.allCases, id: \.self) { currency in
                        Text(currency.rawValue)
                            .tag(currency)
                    }
                }
                .labelsHidden()
                .frame(width: 60)
                TextField("", text: $stringValue)
            }
        }
        .onChange(of: value, perform: onValueChange)
        .onChange(of: stringValue, perform: onStringValueChange)
        .onAppear(perform: handleOnAppear)
    }

    private func onStringValueChange(_ newValue: String) {
        let sanitizedString = String(newValue.sanitizedDouble)
        if sanitizedString != stringValue {
            stringValue = sanitizedString
        }
    }

    private func onValueChange(_ newValue: Double) {
        let sanitizedValue = String(String(newValue).sanitizedDouble)
        if sanitizedValue != stringValue {
            stringValue = sanitizedValue
        }
    }

    private func handleOnAppear() {
        stringValue = String(value)
    }
}

struct MoneyTextField_Previews: PreviewProvider {
    static var previews: some View {
        MoneyTextField(currency: .constant(.EUR), value: .constant(0.12), title: "Price")
    }
}
