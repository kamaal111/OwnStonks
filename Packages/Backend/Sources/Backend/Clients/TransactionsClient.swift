//
//  TransactionsClient.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Models
import Swinject
import ZaWarudo
import CDPersist
import Foundation

public final class TransactionsClient {
    let persistenceController: PersistenceController

    public init(preview: Bool = false) {
        self.persistenceController = container.resolve(PersistenceController.self, argument: preview)!
    }

    public func list() -> [OSTransaction] {
        #warning("Handle errors as well")
        return try! CoreTransaction
            .list(from: persistenceController.context)
            .map(\.osTransaction)
    }

    @discardableResult
    public func create(_ transaction: OSTransaction) -> OSTransaction {
        let newTransaction = CoreTransaction(context: persistenceController.context)
        newTransaction.updateDate = Current.date()
        newTransaction.kCreationDate = Current.date()
        newTransaction.id = Current.uuid()
        newTransaction.assetName = transaction.assetName
        newTransaction.transactionDate = transaction.date
        newTransaction.transactionType = transaction.type.rawValue
        newTransaction.amount = transaction.amount
        newTransaction.pricePerUnit = transaction.pricePerUnit.amount
        newTransaction.pricePerUnitCurrency = transaction.pricePerUnit.currency.rawValue
        newTransaction.fees = transaction.fees.amount
        newTransaction.feesCurrency = transaction.fees.currency.rawValue

        #warning("Handle errors as well")
        try! persistenceController.context.save()

        return newTransaction.osTransaction
    }
}
