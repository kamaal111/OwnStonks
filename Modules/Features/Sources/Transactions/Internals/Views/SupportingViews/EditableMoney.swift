//
//  EditableMoney.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import AppUI
import SwiftUI
import ForexKit
import KamaalUI

struct EditableMoney: View {
    @Binding var currency: Currencies
    @Binding var value: String

    let label: String
    let isEditing: Bool

    init(currency: Binding<Currencies>, value: Binding<String>, label: String, isEditing: Bool) {
        self._currency = currency
        self._value = value
        self.label = label
        self.isEditing = isEditing
    }

    var body: some View {
        if isEditing {
            MoneyField(
                currency: $currency,
                value: $value,
                title: label,
                currencies: Currencies.allCases.filter { !$0.isCryptoCurrency },
                fixButtonTitle: NSLocalizedString("Fix", bundle: .module, comment: ""),
                fixMessage: NSLocalizedString("Invalid value", bundle: .module, comment: "")
            )
        } else {
            AppLabel(title: label, value: Money(value: Double(value) ?? 0, currency: currency).localized)
        }
    }
}

#Preview {
    EditableMoney(currency: .constant(.AUD), value: .constant("200.0"), label: "Money", isEditing: false)
}
