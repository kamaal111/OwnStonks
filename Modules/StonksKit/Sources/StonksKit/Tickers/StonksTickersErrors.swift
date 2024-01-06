//
//  StonksTickersErrors.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalNetworker

public enum StonksTickersErrors: Error {
    case notFound(context: Error)
    case badRequest(context: Error)
    case general(context: Error)

    static func fromNetworker(_ error: KamaalNetworker.Errors) -> StonksTickersErrors {
        switch error {
        case let .generalError(error): .general(context: error)
        case let .responseError(_, code):
            switch code {
            case 400: .badRequest(context: error)
            case 404: .notFound(context: error)
            default: .general(context: error)
            }
        case .notAValidJSON: .general(context: error)
        case let .parsingError(error): .general(context: error)
        case .invalidURL: .general(context: error)
        }
    }
}
