//
//  StonksHealthErrors.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalNetworker

public enum StonksHealthErrors: Error {
    case general

    static func fromNetworker(_: KamaalNetworker.Errors) -> StonksHealthErrors {
        .general
    }
}
