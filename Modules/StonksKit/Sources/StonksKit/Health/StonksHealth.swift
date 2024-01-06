//
//  StonksHealth.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation

public class StonksHealth: BaseStonksKitClient {
    public func ping() async -> Result<StonksHealthPingResponse, StonksHealthErrors> {
        let url = clientURL
            .appending(path: "ping")
        return await get(url: url)
            .mapError(StonksHealthErrors.fromNetworker(_:))
    }

    private var clientURL: URL {
        Self.BASE_URL
            .appending(path: "health")
    }
}
