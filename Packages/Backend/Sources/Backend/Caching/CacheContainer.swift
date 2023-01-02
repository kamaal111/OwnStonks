//
//  CacheContainer.swift
//  
//
//  Created by Kamaal M Farah on 02/01/2023.
//

import Models
import Foundation

protocol CacheContainerable {
    var exchangeRates: [Date : [ExchangeRates]]? { get set }
}

class CacheContainer: CacheContainerable {
    var exchangeRates: [Date : [ExchangeRates]]? {
        get {
            UserDefaults.exchangeRates
        }
        set {
            UserDefaults.exchangeRates = newValue
        }
    }
}
