//
//  Dictionary+extensions.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 19/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

extension Dictionary {
    var urlQueryItems: [URLQueryItem] {
        self.compactMap({ (key: Key, value: Value?) in
            guard let keyString = key as? String, let valueString = value as? String else { return nil }
            return URLQueryItem(name: keyString, value: valueString)
        })
    }
}
