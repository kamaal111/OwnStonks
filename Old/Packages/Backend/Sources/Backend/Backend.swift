//
//  Backend.swift
//
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import CDPersist
import Foundation

public class Backend {
    public let transactions: TransactionsClient
    public let forex: ForexClient

    public init(
        preview: Bool = false,
        urlSession: URLSession = .shared,
        persistenceController: PersistenceController = .shared
    ) {
        self.transactions = TransactionsClient(persistenceController: persistenceController)
        self.forex = ForexClient(preview: preview, urlSession: urlSession)
    }

    public static let shared = Backend()

    public static let preview = Backend(preview: true)
}
