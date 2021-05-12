//
//  PortfolioTotalsSection.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 12/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

struct PortfolioTotalsSection: View {
    var body: some View {
        HStack {
            Text("Totals")
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.TotalsBackground)
        .cornerRadius(8)
        .padding(.all, 8)
    }
}

struct PortfolioTotalsSection_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioTotalsSection()
    }
}
