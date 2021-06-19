//
//  NetworkController.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 19/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation
import StonksNetworker
import ShrimpExtensions
import XiphiasNet
import ConsoleSwift

final class NetworkController {

    private let networker = StonksNetworker()

    enum InfoErrors: Error {
        case noSymbol
        case generalError
    }

    @available(macOS 12.0, *)
    func getInfo(of symbol: String) async -> Result<InfoResponse, InfoErrors> {
        guard !symbol.trimmingByWhitespacesAndNewLines.isEmpty else {
            return .failure(.noSymbol)
        }
        let result = await networker.getInfo(of: symbol)
        let info: InfoResponse
        switch result {
        case let .failure(error):
            console.log(Date(), error.localizedDescription, error)
            if let error = error as? XiphiasNet.NetworkerErrors {
                switch error {
                case .responseError(_, _): return .failure(.generalError)
                case .dataError, .notAValidJSON: return .failure(.generalError)
                }
            }
            return .failure(.generalError)
        case let .success(success):
            guard let success = success, let infoValue = success.first?.value else {
                return .failure(.generalError)
            }
            info = infoValue
        }
        return .success(info)
    }

}
