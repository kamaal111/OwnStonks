//
//  EditableMoney.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import ForexKit
import KamaalUI
import SharedModels

public struct EditableMoney: View {
    @Binding var currency: Currencies
    @Binding var value: String

    public let label: String
    public let isEditing: Bool
    public let show: Bool

    public init(currency: Binding<Currencies>, value: Binding<String>, label: String, isEditing: Bool, show: Bool) {
        self._currency = currency
        self._value = value
        self.label = label
        self.isEditing = isEditing
        self.show = show
    }

    public var body: some View {
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
            AppLabel(title: label, value: moneyLabel)
                .foregroundColor(labelColor)
        }
    }

    private var labelColor: Color {
        if !show {
            return .secondary
        }

        return .primary
    }

    private var moneyLabel: String {
        assert(!isEditing)
        if !show {
            return "***"
        }

        return money.localized
    }

    private var money: Money {
        Money(value: Double(value) ?? 0, currency: currency)
    }
}

#Preview {
    EditableMoney(currency: .constant(.AUD), value: .constant("200.0"), label: "Money", isEditing: false, show: true)
}
