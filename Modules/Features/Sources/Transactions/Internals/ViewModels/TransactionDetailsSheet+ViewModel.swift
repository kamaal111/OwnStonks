//
//  TransactionDetailsSheet+ViewModel.swift
//
//
//  Created by Kamaal M Farah on 06/01/2024.
//

import SwiftUI
import ForexKit
import StonksKit
import SharedModels
import KamaalLogger
import ValutaConversion
import KamaalExtensions

extension TransactionDetailsSheet {
    @Observable
    final class ViewModel {
        var name: String
        var transactionDate: Date
        var transactionType: TransactionTypes
        var amount: String
        var pricePerUnitCurrency: Currencies {
            didSet { pricePerUnitCurrencyDidSet() }
        }

        var pricePerUnit: String
        var feesCurrency: Currencies
        var fees: String
        private(set) var isEditing: Bool
        var assetDataSource: AssetDataSources
        var autoTrackAsset: Bool
        var assetTicker: String
        var showErrorAlert = false
        var errorAlertTitle = ""
        var loading = false

        let context: TransactionDetailsSheetContext
        let isNew: Bool
        private let stonksKit: StonksKit
        private let logger = KamaalLogger(from: TransactionDetailsSheet.self, failOnError: true)

        convenience init(context: TransactionDetailsSheetContext) {
            let stonksKit = StonksKit()
            self.init(context: context, stonksKit: stonksKit)
        }

        convenience init(context: TransactionDetailsSheetContext, stonksKit: StonksKit) {
            switch context {
            case let .new(preferredCurrency):
                self.init(
                    context: context,
                    name: "",
                    transactionDate: Date(),
                    transactionType: .buy,
                    amount: 0,
                    pricePerUnit: Money(value: 0, currency: preferredCurrency),
                    fees: Money(value: 0, currency: preferredCurrency),
                    isEditing: true,
                    isNew: true,
                    autoTrackAsset: false,
                    assetDataSource: .stocks,
                    assetTicker: "",
                    stonksKit: stonksKit
                )
            case let .details(transaction):
                self.init(
                    context: context,
                    name: transaction.name,
                    transactionDate: transaction.transactionDate,
                    transactionType: transaction.transactionType,
                    amount: transaction.amount,
                    pricePerUnit: transaction.pricePerUnit,
                    fees: transaction.fees,
                    isEditing: false,
                    isNew: false,
                    autoTrackAsset: transaction.dataSource != nil,
                    assetDataSource: transaction.dataSource?.sourceType ?? .stocks,
                    assetTicker: transaction.dataSource?.ticker ?? "",
                    stonksKit: stonksKit
                )
            case let .edit(transaction):
                self.init(
                    context: context,
                    name: transaction.name,
                    transactionDate: transaction.transactionDate,
                    transactionType: transaction.transactionType,
                    amount: transaction.amount,
                    pricePerUnit: transaction.pricePerUnit,
                    fees: transaction.fees,
                    isEditing: true,
                    isNew: false,
                    autoTrackAsset: transaction.dataSource != nil,
                    assetDataSource: transaction.dataSource?.sourceType ?? .stocks,
                    assetTicker: transaction.dataSource?.ticker ?? "",
                    stonksKit: stonksKit
                )
            }
        }

        init(
            context: TransactionDetailsSheetContext,
            name: String,
            transactionDate: Date,
            transactionType: TransactionTypes,
            amount: Double,
            pricePerUnit: Money,
            fees: Money,
            isEditing: Bool,
            isNew: Bool,
            autoTrackAsset: Bool,
            assetDataSource: AssetDataSources,
            assetTicker: String,
            stonksKit: StonksKit
        ) {
            self.context = context
            self.name = name
            self.transactionDate = transactionDate
            self.transactionType = transactionType
            self.amount = String(amount)
            self.pricePerUnitCurrency = pricePerUnit.currency
            self.pricePerUnit = String(pricePerUnit.value)
            self.feesCurrency = fees.currency
            self.fees = String(fees.value)
            self.isEditing = isEditing
            self.isNew = isNew
            self.autoTrackAsset = autoTrackAsset
            self.assetDataSource = assetDataSource
            self.assetTicker = assetTicker
            self.stonksKit = stonksKit
        }

        var transactionIsValid: Bool {
            transaction != nil && ((autoTrackAsset && validAssetDataSource != nil) || !autoTrackAsset)
        }

        var title: String {
            switch context {
            case .new: NSLocalizedString("Add Transaction", bundle: .module, comment: "")
            case let .details(transaction): transaction.name
            case let .edit(transaction): transaction.name
            }
        }

        var transaction: AppTransaction? {
            guard !name.trimmingByWhitespacesAndNewLines.isEmpty else { return nil }
            guard let amount = Double(amount) else { return nil }
            guard let pricePerUnit = Double(pricePerUnit) else { return nil }
            guard let fees = Double(fees) else { return nil }

            var id: UUID?
            var creationDate: Date?
            var updatedDate: Date?
            switch context {
            case .new: break
            case let .details(transaction), let .edit(transaction):
                id = transaction.id
                creationDate = transaction.creationDate
                updatedDate = transaction.updatedDate
            }

            return AppTransaction(
                id: id,
                name: name,
                transactionDate: transactionDate,
                transactionType: transactionType,
                amount: amount,
                pricePerUnit: Money(value: pricePerUnit, currency: pricePerUnitCurrency),
                fees: Money(value: fees, currency: feesCurrency),
                dataSource: validAssetDataSource,
                updatedDate: updatedDate,
                creationDate: creationDate
            )
        }

        func fetchPricePerUnit(valutaConversion: ValutaConversion) async {
            await withLoading { [weak self] in
                guard let self else { return }

                guard let validAssetDataSource else {
                    assertionFailure("Expected data source to be valid")
                    return
                }

                let infoResult = await stonksKit.tickers.info(for: validAssetDataSource.ticker, date: transactionDate)
                let info: StonksTickersInfoResponse
                switch infoResult {
                case let .failure(failure):
                    await openAlert(title: NSLocalizedString("Failed to sync price", bundle: .module, comment: ""))
                    logger.warning("Failed to sync price; error='\(failure)'")
                    return
                case let .success(success): info = success
                }

                guard let currency = info.currency, let currency = Currencies(rawValue: currency) else { return }

                let close = Money(value: info.close, currency: currency)
                if let convertedClose = valutaConversion.convertMoney(from: close, to: pricePerUnitCurrency) {
                    await setPricePerUnit(convertedClose)
                } else {
                    await setPricePerUnit(close)
                }
            }
        }

        func finalizeEditing(
            close: @escaping () -> Void,
            done: @escaping (_ transaction: AppTransaction) -> Void
        ) async {
            await withLoading { [weak self] in
                guard let self else { return }

                guard let transaction else {
                    assertionFailure("Expected transaction to be valid here")
                    return
                }

                let tickerIsValid = await validateTicker()
                guard tickerIsValid else {
                    await openAlert(title: NSLocalizedString("Invalid ticker provided", bundle: .module, comment: ""))
                    return
                }
                done(transaction)
                if case .details = context {
                    await disableEditing()
                } else {
                    close()
                }
            }
        }

        @MainActor
        func enableEditing() {
            withAnimation { isEditing = true }
        }

        @MainActor
        func disableEditing() {
            isEditing = false
        }

        private var validAssetDataSource: AppTransactionDataSource? {
            guard autoTrackAsset,
                  assetTicker.rangeOfCharacter(from: .whitespacesAndNewlines) == nil,
                  !assetTicker.isEmpty else { return nil }

            return AppTransactionDataSource(sourceType: assetDataSource, ticker: assetTicker, recordID: nil)
        }

        @MainActor
        private func setPricePerUnit(_ money: Money) {
            pricePerUnit = String(money.value)
            pricePerUnitCurrency = money.currency
        }

        @MainActor
        private func openAlert(title: String) {
            showErrorAlert = true
            errorAlertTitle = title
        }

        private func validateTicker() async -> Bool {
            guard let validAssetDataSource else {
                assertionFailure("Expected data source to be valid")
                return false
            }

            let result = await stonksKit.tickers.tickerIsValid(validAssetDataSource.ticker)
            switch result {
            case let .failure(failure):
                logger.error(label: "Failed to know whether ticker is valid or not", error: failure)
                return false
            case let .success(success): return success
            }
        }

        private func withLoading(completion: @escaping () async -> Void) async {
            await setLoading(true)
            await completion()
            await setLoading(false)
        }

        @MainActor
        private func setLoading(_ value: Bool) {
            if value != loading {
                loading = value
            }
        }

        private func pricePerUnitCurrencyDidSet() {
            if feesCurrency != pricePerUnitCurrency {
                feesCurrency = pricePerUnitCurrency
            }
        }
    }
}
