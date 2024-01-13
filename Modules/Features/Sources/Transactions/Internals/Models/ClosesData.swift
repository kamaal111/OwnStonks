//
//  ClosesData.swift
//
//
//  Created by Kamaal M Farah on 13/01/2024.
//

import ForexKit
import Foundation

struct ClosesData: Hashable {
    let currency: Currencies
    let data: [Date: Double]

    var lastClose: Double? {
        guard let lastCloseDate = data.keys.max() else { return nil }
        return data[lastCloseDate]
    }

    var lowestClose: Double? {
        data.values.min()
    }

    var highestClose: Double? {
        data.values.max()
    }
}
