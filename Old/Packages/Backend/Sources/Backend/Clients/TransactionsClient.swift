//
//  TransactionsClient.swift
//
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Models
import Logster
import ZaWarudo
import CDPersist
import Foundation
import ShrimpExtensions

private let logger = Logster(from: TransactionsClient.self)

public struct TransactionsClient {
    private let persistenceController: PersistenceController

    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    public enum Errors: Error {
        case listingError(context: Error)
        case creationError(context: Error)
        case updateError(context: Error)
        case deleteError(context: Error?)
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

    public func delete(_ transaction: OSTransaction) -> Result<Void, Errors> {
        guard let transactionID = transaction.id else {
            logger.error("Uncomitted transaction found")
            assertionFailure("Uncomitted transaction found")
            return .success(())
        }

        let predicate = NSPredicate(format: "id = %@", transactionID.nsString)
        let foundTransaction: CoreTransaction?
        do {
            foundTransaction = try CoreTransaction.find(by: predicate, from: persistenceController.context)
        } catch {
            assertionFailure("Should have found transaction")
            return .failure(.deleteError(context: error))
        }

        guard let foundTransaction else {
            assertionFailure("Should have found transaction")
            return .failure(.deleteError(context: nil))
        }

        do {
            try foundTransaction.delete()
        } catch {
            return .failure(.deleteError(context: error))
        }

        return .success(())
    }

    public func updateMultiple(_ transactions: [OSTransaction]) -> Result<[OSTransaction], Errors> {
        let transactionIDs = transactions.compactMap(\.id)
        assert(
            transactionIDs.count == transactions.count,
            "Transaction IDs count and transaction count should be exactly the same"
        )

        guard !transactionIDs.isEmpty else {
            assertionFailure("Prevent this by happening here, should have been caught before")
            return .success([])
        }

        let predicate = NSPredicate(format: "id IN %@", transactionIDs.map(\.nsString))
        let foundTransactions: [CoreTransaction]
        do {
            foundTransactions = try CoreTransaction.filter(by: predicate, from: persistenceController.context)
        } catch {
            foundTransactions = []
            logger.error(label: "Failed to get filtered transactions", error: error)
            assertionFailure("Failed to get filtered transactions; \(error)")
        }

        assert(foundTransactions.count == transactions.count, "Should find all input transactions")

        let transactionPairs = foundTransactions
            .compactMap { transaction -> (found: CoreTransaction, input: OSTransaction)? in
                guard let input = transactions.find(by: \.id, is: transaction.id) else {
                    assertionFailure("Should never come here!")
                    return nil
                }

                return (found: transaction, input: input)
            }
        assert(transactionPairs.count == transactions.count, "Should be exactly the same")

        var updatedTransactions: [CoreTransaction] = []
        var errors: [Error] = []
        for (index, pair) in transactionPairs.enumerated() {
            let updatedTransaction: CoreTransaction
            do {
                updatedTransaction = try pair.found.update(
                    from: pair.input,
                    save: index == (transactions.count - 1)
                )
            } catch {
                errors = errors.appended(error)
                logger.error(label: "Error recieved while updating", error: error)
                assertionFailure("Error recieved while updating")
                continue
            }

            updatedTransactions = updatedTransactions.appended(updatedTransaction)
        }

        guard errors.isEmpty else { return .failure(.updateError(context: errors.first!)) }

        assert(updatedTransactions.count == transactions.count, "Should have updated all transactions")
        return .success(updatedTransactions.map(\.osTransaction))
    }

    public func createMultiple(_ transactions: [OSTransaction]) -> Result<[OSTransaction], Errors> {
        var createdTransactions: [CoreTransaction] = []
        var errors: [Error] = []
        for (index, transaction) in transactions.enumerated() {
            let newTransaction: CoreTransaction
            do {
                newTransaction = try CoreTransaction.create(
                    from: transaction,
                    using: persistenceController.context,
                    save: index == (transactions.count - 1)
                )
            } catch {
                errors = errors.appended(error)
                continue
            }

            createdTransactions = createdTransactions.appended(newTransaction)
        }

        guard errors.isEmpty else { return .failure(.creationError(context: errors.first!)) }

        assert(createdTransactions.count == transactions.count, "Should have created all provided transaction")
        return .success(createdTransactions.map(\.osTransaction))
    }
}
