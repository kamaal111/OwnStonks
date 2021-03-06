//
//  EditTransactionFields.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 13/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI
import SalmonUI
import StonksLocale
import ConsoleSwift

struct EditTransactionFields: View {
    @State private var loadingInfo = false

    @Binding var investment: String
    @Binding var costPerShare: Double
    @Binding var shares: Double
    @Binding var transactionDate: Date
    @Binding var symbol: String

    let currency: String
    let getActualPrice: () async -> Void

    var body: some View {
        FloatingTextField(text: $investment, title: .INVESTMENT_LABEL)
        HStack {
            FloatingTextField(text: $symbol, title: .SYMBOL)
            if loadingInfo {
                LoadingView(isLoading: $loadingInfo)
                    .frame(height: 40)
            } else {
                Button(action: {
                    loadingInfo = true
                    if #available(macOS 12.0, *) {
                        detach {
                            await getActualPrice()
                            loadingInfo = false
                        }
                    } else {
                        console.log(Date(), "async await is not available")
                    }
                }) {
                    Text(localized: .GET_INFO)
                }
            }
        }
        EnforcedFloatingDecimalField(
            value: $costPerShare,
            title: StonksLocale.Keys.COST_SHARE_LABEL.localized(with: currency))
        EnforcedFloatingDecimalField(value: $shares, title: .SHARES_LABEL)
        FloatingDatePicker(value: $transactionDate, title: .TRANSACTION_DATE_LABEL)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EditTransactionFields_Previews: PreviewProvider {
    static var previews: some View {
        EditTransactionFields(
            investment: .constant(""),
            costPerShare: .constant(0),
            shares: .constant(0),
            transactionDate: .constant(Date()),
            symbol: .constant(""),
            currency: "$",
            getActualPrice: { })
    }
}
