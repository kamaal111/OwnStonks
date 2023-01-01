//
//  Backend.swift
//
//
//  Created by Kamaal M Farah on 31/12/2022.
//

public class Backend {
    public let transactions: TransactionsClient
    public let forex: ForexClient

    private init(preview: Bool = false) {
        self.transactions = TransactionsClient(preview: preview)
        self.forex = ForexClient(preview: preview)
    }

    public static let shared = Backend()

    public static let preview = Backend(preview: true)
}
