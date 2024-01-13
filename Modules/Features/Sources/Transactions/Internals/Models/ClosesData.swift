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
}
