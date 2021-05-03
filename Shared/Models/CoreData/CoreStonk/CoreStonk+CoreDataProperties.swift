//
//  CoreStonk+CoreDataProperties.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//
//

import Foundation
import CoreData


extension CoreStonk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreStonk> {
        return NSFetchRequest<CoreStonk>(entityName: "CoreStonk")
    }

    @NSManaged public var name: String
    @NSManaged public var shares: Double
    @NSManaged public var costs: Double
    @NSManaged public var symbol: String?

}

extension CoreStonk : Identifiable {

}
