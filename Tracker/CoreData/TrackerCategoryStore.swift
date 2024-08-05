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
    
    func addNewTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryForDB = TrackerCategoryCD(context: context)
        var trackers: [TrackerCD] = []
        //TODO: Инициализировать Категорию
        trackerCategoryForDB.title = trackerCategory.title
        for i in trackerCategory.trackers {
            let trackerForDB = trackerStore.createNewTracker(tracker: i, category: trackerCategoryForDB)
            trackers.append(trackerForDB)
            trackerForDB.category = trackerCategoryForDB
            trackerCategoryForDB.addToTrackers(trackerForDB)
        }
        
        try context.save()
    }
    
    func fetchRequest() -> NSFetchRequest<TrackerCategoryCD> {
        return NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
    }
}
