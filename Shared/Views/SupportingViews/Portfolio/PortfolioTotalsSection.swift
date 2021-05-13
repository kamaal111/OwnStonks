//
//  PortfolioTotalsSection.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 12/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

struct PortfolioTotalsSection: View {
    let total: String

    var body: some View {
        HStack {
            Text("Total: \(total)")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color.TotalsBackground)
        .cornerRadius(8)
        .padding(.all, 8)
    }
}

struct PortfolioTotalsSection_Previews: PreviewProvider {
    static var previews: some View {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return PortfolioTotalsSection(total: formatter.string(from: 12) ?? "")
            .previewLayout(.sizeThatFits)
            .padding(8)
    }
}
