//
//  Backend.swift
//
//
//  Created by Kamaal M Farah on 31/12/2022.
//

public final class Backend {
    public let transactions: TransactionsClient

    public init(preview: Bool = false) {
        self.transactions = TransactionsClient(preview: preview)
    }
}
