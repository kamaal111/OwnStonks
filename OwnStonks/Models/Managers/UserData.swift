//
//  UserData.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/01/2023.
//

import Models
import Foundation

final class UserData: ObservableObject {
    @Published private var preferedCurrency: Currencies?
}
