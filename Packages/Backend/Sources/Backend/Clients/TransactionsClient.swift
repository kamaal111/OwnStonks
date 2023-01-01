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

        let updatedTransaction: CoreTransaction
        do {
            updatedTransaction = try foundTransaction.update(from: transaction)
        } catch {
            return .failure(.updateError(context: error))
        }

        return .success(updatedTransaction.osTransaction)
    }

    public func create(_ transaction: OSTransaction) -> Result<OSTransaction, Errors> {
        let newTransaction: CoreTransaction
        do {
            newTransaction = try CoreTransaction.create(from: transaction, using: persistenceController.context)
        } catch {
            return .failure(.creationError(context: error))
        }

        return .success(newTransaction.osTransaction)
    }
}
