//
//  TrackerStore.swift
//  Tracker
//
//  Created by Илья Волощик on 30.07.24.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTracker(_ tracker: Tracker) throws {
        let trackerForDB = TrackerCD(context: context)
        trackerForDB.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerForDB.emoji = tracker.emoji
        trackerForDB.identifier = tracker.identifier
        trackerForDB.timetable = tracker.timetable.toString()
        trackerForDB.name = tracker.name
        try context.save()
    }
    
    func createNewTracker(tracker: Tracker, category: TrackerCategoryCD) -> TrackerCD {
        let trackerForDB = TrackerCD(context: context)
        //TODO: Инициализировать Трекер
        trackerForDB.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerForDB.emoji = tracker.emoji
        trackerForDB.identifier = tracker.identifier
        trackerForDB.timetable = tracker.timetable.toString()
        trackerForDB.name = tracker.name
        trackerForDB.category = category
        return trackerForDB
    }
    
    func fetchRequest() -> NSFetchRequest<TrackerCD> {
        return NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
    }

}
