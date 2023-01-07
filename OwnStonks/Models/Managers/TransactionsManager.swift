//
//  TransactionsManager.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Models
import SwiftUI
import Backend
import Logster
import PopperUp
import OSLocales
import ShrimpExtensions

private let logger = Logster(from: TransactionsManager.self)

final class TransactionsManager: ObservableObject {
    @Published private(set) var transactions: [OSTransaction] = []
    @Published private(set) var isLoading = false

    private let backend: Backend

    init(backend: Backend = .shared) {
        self.backend = backend
    }

    func fetch() async -> Result<Void, Errors> {
        await benchmark(function: {
            await wrapLoading({
                logger.info("Fetching transactions")

                let transactions: [OSTransaction]
                let transactionsResult = backend.transactions.list()
                switch transactionsResult {
                case .failure(let failure):
                    return .failure(.fromTransactionClientError(failure))
                case .success(let success):
                    transactions = success
                }

                await setTransactions(transactions)
                return .success(())
            })
        }, duration: { duration in
            logger.info("Successfully fetched transactions in \((duration) * 1000) ms")
        })
    }

    func deleteTransaction(_ transaction: OSTransaction) async -> Result<Void, Errors> {
        guard let transactionID = transaction.id,
              let transactionIndex = transactions.findIndex(by: \.id, is: transactionID) else {
            assertionFailure("Should have had a ID")
            return .success(())
        }

        let result = backend.transactions.delete(transaction)
        switch result {
        case .failure(let failure):
            return .failure(.fromTransactionClientError(failure))
        case .success:
            break
        }

        await setTransactions(transactions.removed(at: transactionIndex))
        logger.info("Deleted transaction with ID \(transactionID)")
        return .success(())
    }

    func updateTransactions(_ transactions: [OSTransaction]) async -> Result<Void, Errors> {
        let updateTransactionsResult = backend.transactions.updateMultiple(transactions)
        let updatedTransactions: [OSTransaction]
        switch updateTransactionsResult {
        case .failure(let failure):
            return .failure(.fromTransactionClientError(failure))
        case .success(let success):
            updatedTransactions = success
        }

        for transaction in updatedTransactions {
            await updateTransactionInTransactions(transaction)
            logger.info("Updated transaction with ID \(transaction.id?.uuidString ?? "(null)")")
        }

        return .success(())
    }

    func addTransaction(_ transactions: [OSTransaction]) async -> Result<Void, Errors> {
        await benchmark(function: {
            let newTransactions: [OSTransaction]
            let createTransactionsResult = backend.transactions.createMultiple(transactions)
            switch createTransactionsResult {
            case .failure(let failure):
                return .failure(.fromTransactionClientError(failure))
            case .success(let success):
                newTransactions = success
            }

            await setTransactions(self.transactions.concat(newTransactions))

            return .success(())
        }, duration: { duration in logger.info("Successfully saved transactions in \((duration) * 1000) ms") })
    }

    @MainActor
    private func setTransactions(_ transactions: [OSTransaction]) {
        let transactions = transactions
            .filter({ $0.id != nil })
            .sorted(by: \.date, using: .orderedDescending)

        withAnimation { self.transactions = transactions }
    }

    @MainActor
    private func updateTransactionInTransactions(_ transaction: OSTransaction) {
        guard let transactionID = transaction.id,
              let foundTransactionIndex = transactions.findIndex(by: \.id, is: transactionID) else {
            assertionFailure("Failed to find transaction")
            return
        }

        transactions[foundTransactionIndex] = transaction
    }

    private func benchmark<T>(function: () async -> T, duration: (_ duration: TimeInterval) -> Void) async -> T {
        #warning("Duplicate code")
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        let result = await function()
        duration(info.systemUptime - begin)
        return result
    }

    private func wrapLoading<T>(_ function: () async -> T) async -> T {
        await setIsLoading(true)
        let result = await function()
        await setIsLoading(false)
        return result
    }

    @MainActor
    private func setIsLoading(_ state: Bool) {
        isLoading = state
    }
}

extension TransactionsManager {
    enum Errors: Error {
        case fetchError(context: TransactionsClient.Errors)
        case createError(context: TransactionsClient.Errors)
        case updateError(context: TransactionsClient.Errors)
        case deleteError(context: TransactionsClient.Errors?)

        var popUpStyle: PopperUpStyles {
            switch self {
            case .fetchError:
                logger.error(label: "Failed to fetch transactions", error: self)
                assertionFailure("Failed to fetch transactions")
                return .bottom(
                    title: OSLocales.getText(.GENERAL_ERROR_TITLE),
                    type: .error,
                    description: OSLocales.getText(.FETCH_TRANSACTIONS_FAILURE_DESCRIPTION))
            case .createError:
                logger.error(label: "Failed to create this transaction", error: self)
                assertionFailure("Failed to create this transaction")
                return .bottom(
                    title: OSLocales.getText(.GENERAL_ERROR_TITLE),
                    type: .error,
                    description: OSLocales.getText(.CREATE_TRANSACTION_FAILURE_DESCRIPTION))
            case .updateError:
                logger.error(label: "Failed to update this transaction", error: self)
                assertionFailure("Failed to update this transaction")
                return .bottom(
                    title: OSLocales.getText(.GENERAL_ERROR_TITLE),
                    type: .error,
                    description: OSLocales.getText(.UPDATE_TRANSACTION_FAILURE_DESCRIPTION))
            case .deleteError:
                logger.error(label: "Failed to delete transaction", error: self)
                assertionFailure("Failed to delete transaction")
                return .bottom(
                    title: OSLocales.getText(.GENERAL_ERROR_TITLE),
                    type: .error,
                    description: OSLocales.getText(.DELETE_TRANSACTION_FAILURE_DESCRIPTION))
            }
        }

        static func fromTransactionClientError(_ error: TransactionsClient.Errors) -> Errors {
            switch error {
            case .listingError:
                return .fetchError(context: error)
            case .creationError:
                return .createError(context: error)
            case .updateError:
                return .updateError(context: error)
            case .deleteError:
                return .deleteError(context: error)
            }
        }
    }
}
