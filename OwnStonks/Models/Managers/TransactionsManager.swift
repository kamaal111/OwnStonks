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
import Swinject
import OSLocales
import ShrimpExtensions

private let logger = Logster(from: TransactionsManager.self)

final class TransactionsManager: ObservableObject {
    @Published private(set) var transactions: [OSTransaction] = []

    private let preview: Bool

    init(preview: Bool = false) {
        self.preview = preview
    }

    func fetch() async -> Result<Void, Errors> {
        await benchmark(function: {
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
        }, duration: { duration in
            logger.info("Successfully fetched transactions in \((duration) * 1000) ms")
        })
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
    }

    private var backend: Backend {
        container.resolve(Backend.self, argument: preview)!
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
}

extension TransactionsManager {
    enum Errors: Error {
        case fetchError(context: TransactionsClient.Errors)
        case createError(context: TransactionsClient.Errors)
        case updateError(context: TransactionsClient.Errors)
        case uncommitedTransaction(context: TransactionsClient.Errors)

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
            case .uncommitedTransaction:
                logger.error(label: "Failed to find this transaction", error: self)
                assertionFailure("Failed to find this transaction")
                return .bottom(
                    title: OSLocales.getText(.GENERAL_ERROR_TITLE),
                    type: .error,
                    description: OSLocales.getText(.UPDATE_TRANSACTION_FAILURE_DESCRIPTION))
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
            case .uncommitedTransaction:
                return .uncommitedTransaction(context: error)
            }
        }
    }
}
