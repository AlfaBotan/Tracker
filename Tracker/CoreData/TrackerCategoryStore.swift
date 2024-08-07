//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Илья Волощик on 30.07.24.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
   private func fetchRequest() -> NSFetchRequest<TrackerCategoryCD> {
        return NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
    }
}
