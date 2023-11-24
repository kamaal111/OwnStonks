//
//  TransactionInformationLabel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import SwiftUI
import OSLocales

struct TransactionInformationLabel: View {
    let title: OSLocales.Keys
    let value: String

    var body: some View {
        OSText(localized: title, with: [value])
    }
}

struct TransactionInformationLabel_Previews: PreviewProvider {
    static var previews: some View {
        TransactionInformationLabel(title: .FEES_LABEL, value: "$420.00")
    }
}
