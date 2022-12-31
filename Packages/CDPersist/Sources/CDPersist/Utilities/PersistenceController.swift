//
//  PersistenceController.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Logster
import CoreData
import ManuallyManagedObject

private let logger = Logster(from: PersistenceController.self)

/// Utility class to handle core data operations.
public class PersistenceController {
    /// The main queue’s managed object context.
    public var context: NSManagedObjectContext {
        container.viewContext
    }

    /// Main singleton instance to handle core data operations.
    public static let shared = PersistenceController()

    /// Preview singleton to be used for debugging or previewing core data operations.
    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

    private let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        let containerName = "OwnStonks"
        let persistentContainerBuilder = _PersistentContainerBuilder(
            entities: [
                CoreTransaction.entity
            ],
            relationships: [],
            containerName: containerName,
            preview: inMemory
        )
        self.container = persistentContainerBuilder.make()

        if !inMemory, let defaultURL = container.persistentStoreDescriptions.first?.url {
            let defaultStore = NSPersistentStoreDescription(url: defaultURL)
            defaultStore.configuration = "Default"
            defaultStore.shouldMigrateStoreAutomatically = false
            defaultStore.shouldInferMappingModelAutomatically = true
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
                logger.error(label: "Unresolved persistent store error", error: error)
            }
        })
    }
}
