//
//  EditableMoney.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import SwiftUI
import SalmonUI
import OSLocales

struct EditableMoney: View {
    @Binding var currency: Currencies
    @Binding var value: Double

    @State private var stringValue = ""

    let title: String
    let isEditing: Bool

    init(currency: Binding<Currencies>, value: Binding<Double>, title: String, isEditing: Bool) {
        self._currency = currency
        self._value = value
        self.title = title
        self.isEditing = isEditing
    }

    init(currency: Binding<Currencies>, value: Binding<Double>, localized: OSLocales.Keys, isEditing: Bool) {
        self.init(currency: currency, value: value, title: OSLocales.getText(localized), isEditing: isEditing)
    }

    var body: some View {
        if isEditing {
            MoneyTextField(currency: $currency, value: $value, title: title)
        } else {
            OSText("\(title): \(money.localized)")
                .ktakeWidthEagerly(alignment: .leading)
        }
    }

    private var money: Money {
        Money(amount: value, currency: currency)
    }
}

struct EditableMoney_Previews: PreviewProvider {
    static var previews: some View {
        EditableMoney(currency: .constant(.EUR), value: .constant(420), title: "Title", isEditing: false)
    }
}
