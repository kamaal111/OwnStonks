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

    public enum Errors: Error {
        case listingError(context: Error)
        case creationError(context: Error)
    }

    public func list() -> Result<[OSTransaction], Errors> {
        let transactions: [CoreTransaction]
        do {
            transactions = try CoreTransaction.list(from: persistenceController.context)
        } catch {
            return .failure(.listingError(context: error))
        }

        return .success(transactions.map(\.osTransaction))
    }

    public func create(_ transaction: OSTransaction) -> Result<OSTransaction, Errors> {
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

        do {
            try persistenceController.context.save()
        } catch {
            return .failure(.creationError(context: error))
        }

        return .success(newTransaction.osTransaction)
    }
}
