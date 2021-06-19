//
//  Date+extensions.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 19/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

extension Date {
    func getFormattedDateString(withFormat format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
