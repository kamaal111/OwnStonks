//
//  StonksHealth.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation

public class StonksHealth: StonksKitClient {
    public func ping() async -> Result<StonksHealthPingResponse, StonksHealthErrors> {
        let url = clientURL
            .appending(path: "ping")
        return await get(url: url, enableCaching: true)
            .mapError(StonksHealthErrors.fromNetworker(_:))
    }

    private var clientURL: URL {
        Self.BASE_URL
            .appending(path: "health")
    }
}
