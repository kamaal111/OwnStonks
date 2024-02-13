//
//  UserDefaultsSuite.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import Foundation

public class UserDefaultsSuite: UserDefaults {
    private init() {
        super.init(suiteName: "group.io.kamaal.OwnStonks")!
    }

    public static let shared = UserDefaultsSuite()
}
