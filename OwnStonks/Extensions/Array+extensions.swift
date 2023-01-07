//
//  Array+extensions.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import Foundation

extension Array {
    func removed(at index: Int) -> [Element] {
        var array = self
        array.remove(at: index)
        return array
    }
}
