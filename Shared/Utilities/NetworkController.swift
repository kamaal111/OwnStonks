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

final class NetworkController {

    private let networker = StonksNetworker()

    func getInfo(of symbol: String) async {
        guard !symbol.trimmingByWhitespacesAndNewLines.isEmpty else {
            /// - TODO: THROW ERROR HERE
            print("symbol is empty")
            return
        }
        let result = await networker.getInfo(of: symbol)
        let info: [String: InfoResponse]
        switch result {
        case let .failure(error):
            handleError(error: error)
            return
        case let .success(success):
            guard let success = success else {
                /// - TODO: THROW ERROR HERE
                print("No response for some reason")
                return
            }
            info = success
        }
        print(info)
    }

    /// - TODO: Throw appropriate error here
    private func handleError(error: Error) {
        if let error = error as? XiphiasNet.NetworkerErrors {
            switch error {
            case let .responseError(message, code):
                print(error)
                print(message)
                print(code)
                return
            case .dataError:
                print(error)
                return
            case .notAValidJSON:
                print(error)
                return
            }
        }
    }

}
