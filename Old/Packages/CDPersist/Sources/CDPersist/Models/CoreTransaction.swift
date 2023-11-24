//
//  CoreTransaction.swift
//
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Models
import CoreData
import ZaWarudo
import ManuallyManagedObject

@objc(CoreTransaction)
public class CoreTransaction: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var assetName: String
    @NSManaged public var transactionDate: Date
    @NSManaged public var transactionType: String
    @NSManaged public var amount: Double
    @NSManaged public var pricePerUnit: Double
    @NSManaged public var pricePerUnitCurrency: String
    @NSManaged public var fees: Double
    @NSManaged public var feesCurrency: String

    public var osTransaction: OSTransaction {
        OSTransaction(
            id: id,
            assetName: assetName,
            date: transactionDate,
            type: TransactionTypes(rawValue: transactionType)!,
            amount: amount,
            pricePerUnit: Money(amount: pricePerUnit, currency: Currencies(rawValue: pricePerUnitCurrency)!),
            fees: Money(amount: fees, currency: Currencies(rawValue: feesCurrency)!)
        )
    }

    public func update(from transaction: OSTransaction, save: Bool = true) throws -> CoreTransaction {
        updateDate = Current.date()
        assetName = transaction.assetName
        transactionDate = transaction.date
        transactionType = transaction.type.rawValue
        amount = transaction.amount
        pricePerUnit = transaction.pricePerUnit.amount
        pricePerUnitCurrency = transaction.pricePerUnit.currency.rawValue
        fees = transaction.fees.amount
        feesCurrency = transaction.fees.currency.rawValue

        if save {
            try managedObjectContext?.save()
        }

        return self
    }

    public static func create(
        from transaction: OSTransaction,
        using context: NSManagedObjectContext,
        save: Bool = true
    ) throws -> CoreTransaction {
        let newTransaction = try CoreTransaction(context: context)
            .update(from: transaction, save: false)
        newTransaction.id = Current.uuid()
        newTransaction.kCreationDate = Current.date()

        if save {
            try context.save()
        }

        return newTransaction
    }

    public static let properties: [ManagedObjectPropertyConfiguration] = [
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.updateDate, type: .date, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.kCreationDate, type: .date, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.id, type: .uuid, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.assetName, type: .string, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.transactionDate, type: .date, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.transactionType, type: .string, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.amount, type: .double, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.pricePerUnit, type: .double, isOptional: false),
        ManagedObjectPropertyConfiguration(
            name: \CoreTransaction.pricePerUnitCurrency,
            type: .string,
            isOptional: false
        ),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.fees, type: .double, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \CoreTransaction.feesCurrency, type: .string, isOptional: false),
    ]
}
