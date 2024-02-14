//
//  TransactionDetailsSheet+ViewModel.swift
//
//
//  Created by Kamaal M Farah on 06/01/2024.
//

import SwiftUI
import CloudKit
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
        private(set) var isEditing: Bool {
            didSet { isEditingDidSet() }
        }

        var assetDataSource: AssetDataSources
        var autoTrackAsset: Bool
        var assetTicker: String
        var showErrorAlert = false
        var errorAlertTitle = ""
        var loading = false
        var closes: ClosesData?
        private(set) var closesNeedConverting = false

        let context: TransactionDetailsSheetContext
        let isNew: Bool
        private var stonksKit: StonksKit?
        private let logger = KamaalLogger(from: TransactionDetailsSheet.self, failOnError: true)

        convenience init(context: TransactionDetailsSheetContext) {
            self.init(context: context, urlSession: .shared, cacheStorage: TransactionsQuickStorage.shared)
        }

        convenience init(
            context: TransactionDetailsSheetContext,
            urlSession: URLSession,
            cacheStorage: TransactionsQuickStoragable
        ) {
            var stonksKit: StonksKit?
            if let stonksKitURL = SecretsJSON.shared.content?.stonksKitURL {
                stonksKit = StonksKit(baseURL: stonksKitURL, urlSession: urlSession, cacheStorage: cacheStorage)
            }
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

        private init(
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
            stonksKit: StonksKit?
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

        var shouldShowAutoTrackOptions: Bool {
            isEditing && transactionIsValid && autoTrackAsset && stonksKit != nil
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
            var recordID: CKRecord.ID?
            switch context {
            case .new: break
            case let .details(transaction), let .edit(transaction):
                assert(transaction.id != nil && transaction.creationDate != nil && transaction.updatedDate != nil)
                id = transaction.id
                creationDate = transaction.creationDate
                updatedDate = transaction.updatedDate
                recordID = transaction.recordID
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
                creationDate: creationDate,
                recordID: recordID
            )
        }

        func fetchPricePerUnit(valutaConversion: ValutaConversion) async {
            guard let stonksKit else { return }

            await withLoading { [weak self] in
                guard let self else { return }

                guard let validAssetDataSource else {
                    assertionFailure("Expected data source to be valid")
                    return
                }

                let info: StonksTickersInfoResponse
                do {
                    info = try await stonksKit.tickers.info(for: validAssetDataSource.ticker, date: transactionDate)
                        .get()
                } catch {
                    await openAlert(title: NSLocalizedString("Failed to sync price", bundle: .module, comment: ""))
                    logger.warning("Failed to sync price; error='\(error)'")
                    return
                }

                let currency = info.currency
                guard let currency = Currencies(rawValue: currency) else { return }

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

        func fetchCloses() async {
            guard FeatureFlags.previousCloseInTransactionDetailsSheet, let stonksKit else { return }
            guard !isEditing else { return }
            guard case .details = context else { return }
            guard validAssetDataSource != nil else { return }

            await withLoading { [weak self] in
                guard let self else { return }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd'T'hh:mm:ss"
                let closes: ClosesData?
                let closesResult = await stonksKit.tickers.closes(for: assetTicker, startDate: transactionDate)
                    .map { success -> ClosesData? in
                        let closesMappedByDates = success.closesMappedByDates
                        guard !closesMappedByDates.isEmpty else { return nil }

                        let currency = success.currency
                        guard let currency = Currencies(rawValue: currency) else { return nil }
                        return ClosesData(currency: currency, data: closesMappedByDates)
                    }
                switch closesResult {
                case .failure:
                    logger.warning("Failed to fetch closes")
                    return
                case let .success(success): closes = success
                }
                guard let closes else { return }

                await setCloses(closes)
            }
        }

        func convertCloses(valutaConversion: ValutaConversion) async {
            guard let closes else {
                assertionFailure("Should have closes when this function is called")
                return
            }

            var convertedCloses: [Date: Double] = [:]
            for (date, close) in closes.data {
                let convertedValue = valutaConversion.convertMoney(
                    from: .init(value: close, currency: closes.currency),
                    to: pricePerUnitCurrency
                )
                guard let convertedValue else { continue }

                convertedCloses[date] = convertedValue.value
            }
            guard !convertedCloses.isEmpty else { return }

            let newCloses = ClosesData(currency: pricePerUnitCurrency, data: convertedCloses)
            await setCloses(newCloses, closesNeedConverting: false)
        }

        private var validAssetDataSource: AppTransactionDataSource? {
            guard autoTrackAsset else { return nil }
            guard assetTicker.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else { return nil }
            guard !assetTicker.isEmpty else { return nil }

            var recordID: CKRecord.ID?
            var id: UUID?
            var updatedDate: Date?
            var creationDate: Date?
            var transactionRecordID: CKRecord.ID?
            switch context {
            case let .edit(transaction), let .details(transaction):
                id = transaction.dataSource?.id
                recordID = transaction.dataSource?.recordID
                updatedDate = transaction.dataSource?.updatedDate
                creationDate = transaction.dataSource?.creationDate
                transactionRecordID = transaction.recordID
            case .new: break
            }

            return AppTransactionDataSource(
                id: id,
                sourceType: assetDataSource,
                ticker: assetTicker,
                updatedDate: updatedDate,
                creationDate: creationDate,
                transactionRecordID: transactionRecordID,
                recordID: recordID
            )
        }

        func setStonksKit(_ stonksKit: StonksKit) {
            self.stonksKit = stonksKit
        }

        @MainActor
        private func setCloses(_ closes: ClosesData, closesNeedConverting: Bool = true) {
            withAnimation { self.closes = closes }
            self.closesNeedConverting = closesNeedConverting
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
            guard autoTrackAsset else { return true }
            guard let stonksKit else { return false }
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

        private func isEditingDidSet() {
            guard !isEditing else { return }

            Task { await fetchCloses() }
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
