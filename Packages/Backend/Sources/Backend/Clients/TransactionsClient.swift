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
import ShrimpExtensions

public final class TransactionsClient {
    let persistenceController: PersistenceController

    public init(preview: Bool = false) {
        self.persistenceController = container.resolve(PersistenceController.self, argument: preview)!
    }

    public enum Errors: Error {
        case listingError(context: Error)
        case creationError(context: Error)
        case updateError(context: Error)
        case uncommitedTransaction
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

    public func update(_ transaction: OSTransaction) -> Result<OSTransaction, Errors> {
        guard let id = transaction.id?.nsString else { return .failure(.uncommitedTransaction) }

        let predicate = NSPredicate(format: "id = %@", id)
        let foundTransaction: CoreTransaction?
        do {
            foundTransaction = try CoreTransaction.find(by: predicate, from: persistenceController.context)
        } catch {
            return .failure(.updateError(context: error))
        }

        guard let foundTransaction else { return .failure(.uncommitedTransaction) }

        foundTransaction.updateDate = Current.date()
        foundTransaction.assetName = transaction.assetName
        foundTransaction.transactionDate = transaction.date
        foundTransaction.transactionType = transaction.type.rawValue
        foundTransaction.amount = transaction.amount
        foundTransaction.pricePerUnit = transaction.pricePerUnit.amount
        foundTransaction.pricePerUnitCurrency = transaction.pricePerUnit.currency.rawValue
        foundTransaction.fees = transaction.fees.amount
        foundTransaction.feesCurrency = transaction.fees.currency.rawValue

        do {
            try persistenceController.context.save()
        } catch {
            return .failure(.updateError(context: error))
        }

        return .success(foundTransaction.osTransaction)
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
