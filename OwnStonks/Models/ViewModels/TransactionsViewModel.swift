//
//  TransactionsViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Models
import Backend
import Logster
import PopperUp
import Swinject
import OSLocales
import Foundation
import ShrimpExtensions

private let logger = Logster(from: TransactionsViewModel.self)

final class TransactionsViewModel: ObservableObject {
    @Published private(set) var transactions: [OSTransaction] = []

    private let backend: Backend

    init(preview: Bool = false) {
        self.backend = container.resolve(Backend.self, argument: preview)!
    }

    enum Errors: Error {
        case fetchError(context: TransactionsClient.Errors)
        case createError(context: TransactionsClient.Errors)

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
            }
        }

        static func fromTransactionClientError(_ error: TransactionsClient.Errors) -> Errors {
            switch error {
            case .listingError(let context):
                return .fetchError(context: .listingError(context: context))
            case .creationError(let context):
                return .createError(context: .creationError(context: context))
            }
        }
    }

    @MainActor
    func fetch() -> Result<Void, Errors> {
        logger.info("Fetching transactions")

        let transactions: [OSTransaction]
        let transactionsResult = backend.transactions.list()
        switch transactionsResult {
        case .failure(let failure):
            return .failure(.fromTransactionClientError(failure))
        case .success(let success):
            transactions = success
        }

        setTransactions(transactions)
        return .success(())
    }

    @MainActor
    func addTransaction(_ transaction: OSTransaction) -> Result<Void, Errors> {
        let newTransaction: OSTransaction
        let createTransactionResult = backend.transactions.create(transaction)
        switch createTransactionResult {
        case .failure(let failure):
            return .failure(.fromTransactionClientError(failure))
        case .success(let success):
            newTransaction = success
        }

        setTransactions(transactions.appended(newTransaction))
        return .success(())
    }

    @MainActor
    private func setTransactions(_ transactions: [OSTransaction]) {
        self.transactions = transactions
            .sorted(by: \.date, using: .orderedDescending)
    }
}
