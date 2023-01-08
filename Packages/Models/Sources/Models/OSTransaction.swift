//
//  OSTransaction.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import CSVUtils
import Foundation
import ShrimpExtensions

public struct OSTransaction: Hashable, Codable {
    public let id: UUID?
    public let assetName: String
    public let date: Date
    public let type: TransactionTypes
    public let amount: Double
    public let pricePerUnit: Money
    public let fees: Money

    public init(
        id: UUID?,
        assetName: String,
        date: Date,
        type: TransactionTypes,
        amount: Double,
        pricePerUnit: Money,
        fees: Money) {
            self.id = id
            self.assetName = assetName
            self.date = date
            self.type = type
            self.amount = amount
            self.pricePerUnit = pricePerUnit
            self.fees = fees
        }

    public static func fromCSV(data: Data, seperator: Character) throws -> [OSTransaction] {
        let items: [CSVRepresentation] = try CSVUtils.decode(data: data, seperator: ";")
        return items
            .compactMap({ $0.toOSTransaction() })
    }

    struct CSVRepresentation: Codable {
        let type: String
        let name: String
        let perUnit: String
        let amount: String
        let fees: String
        let date: String

        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case name = "Name"
            case perUnit = "Per unit"
            case amount = "Amount"
            case fees = "Fees"
            case date = "Date"
        }

        func toOSTransaction() -> OSTransaction? {
            guard let pricePerUnit = Money.fromString(string: perUnit),
                  let fees = Money.fromString(string: fees),
                  let type = TransactionTypes(rawValue: type.lowercased()),
                  let date = YearMonthDayStrategy.dateFormatter.date(from: date),
                  let amount = amount.localizedStringToDouble else {
                assertionFailure("Failed to decode transcation")
                return nil
            }

            return OSTransaction(
                id: nil,
                assetName: name,
                date: date,
                type: type,
                amount: amount,
                pricePerUnit: pricePerUnit,
                fees: fees)
        }
    }
}
