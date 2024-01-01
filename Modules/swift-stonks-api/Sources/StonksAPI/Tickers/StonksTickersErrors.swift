//
//  StonksTickersErrors.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalNetworker

public enum StonksTickersErrors: Error {
    case notFound
    case badRequest
    case general(context: Error)

    static func fromNetworker(_ error: KamaalNetworker.Errors) -> StonksTickersErrors {
        switch error {
        case let .generalError(error): return .general(context: error)
        case let .responseError(message, code):
            if code == 404 {
                return .notFound
            }
            if code == 400 {
                return .badRequest
            }
            return .general(context: error)
        case .notAValidJSON: return .general(context: error)
        case let .parsingError(error): return .general(context: error)
        case let .invalidURL(url): return .general(context: error)
        }
    }
}
