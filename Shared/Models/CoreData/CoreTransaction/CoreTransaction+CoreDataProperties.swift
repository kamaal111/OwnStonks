//
//  CoreTransaction+CoreDataProperties.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 04/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation
import CoreData


extension CoreTransaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreTransaction> {
        return NSFetchRequest<CoreTransaction>(entityName: "CoreTransaction")
    }

    @NSManaged public var costPerShare: Double
    @NSManaged public var createdDate: Date
    @NSManaged public var name: String
    @NSManaged public var shares: Double
    @NSManaged public var symbol: String?
    @NSManaged public var transactionDate: Date
    @NSManaged public var updatedDate: Date?

}

extension CoreTransaction : Identifiable {

}
