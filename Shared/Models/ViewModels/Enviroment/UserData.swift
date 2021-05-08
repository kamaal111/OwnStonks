//
//  UserData.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 08/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Combine

final class UserData: ObservableObject {

    @Published private(set) var currency = MoneyMoney.getSymbolFromUserDefaults()

}
