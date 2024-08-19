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
    
    private func fetchRequest() -> NSFetchRequest<TrackerCD> {
        return NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
    }
    
    func addNewTracker(tracker: Tracker, categoryName: String) {
        let fetchRequest = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        var categories: [TrackerCategoryCD] = []
        do {
            categories = try context.fetch(fetchRequest)
        } catch {
            print("Не удалось запросить категории")
        }
        
        let category: TrackerCategoryCD
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            category = TrackerCategoryCD(context: context)
            category.title = categoryName
        }
        
        let trackerForDB = TrackerCD(context: context)
        trackerForDB.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerForDB.emoji = tracker.emoji
        trackerForDB.identifier = tracker.identifier
        trackerForDB.timetable = tracker.timetable.toString()
        trackerForDB.name = tracker.name
        
        trackerForDB.category = category
        category.addToTrackers(trackerForDB)
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить изменения в контексте")
        }
    }
    
    private func createTracker(from trackerCD: TrackerCD) -> Tracker? {
        guard let trackerID = trackerCD.identifier,
              let trackerName = trackerCD.name,
              let trackerColorString = trackerCD.color,
              let trackerTimetableString = trackerCD.timetable,
              let trackerEmoji = trackerCD.emoji
        else {
            return nil
        }
        
        let trackerColor = uiColorMarshalling.color(from: trackerColorString)
        let trackerTimetable = trackerTimetableString.toWeekdaysArray()
        
        let tracker = Tracker(identifier: trackerID, name: trackerName, color: trackerColor, emoji: trackerEmoji, timetable: trackerTimetable)
        return tracker
    }
    
    func removeAllTrackers() {
        let request = fetchRequest()
        var trackersFromDB: [TrackerCD] = []
        do {
            trackersFromDB = try context.fetch(request)
        }  catch {
            print("В базе данных нет трекеров")
            return
        }
        for i in trackersFromDB {
            context.delete(i)
        }
        
        do {
            try context.save()
        } catch {
            print("Не удалось удалить все записи о выполненных трекерах")
        }
    }
    
    func getTrackersFromDB() -> [Tracker] {
        var trackersArray: [Tracker] = []
        let request = fetchRequest()
        var trackersFromDB: [TrackerCD] = []
        do {
            trackersFromDB = try context.fetch(request)
        }  catch {
            print("В базе данных нет трекеров")
            return []
        }
        for i in trackersFromDB {
            if let newTracker = createTracker(from: i) {
                trackersArray.append(newTracker)
                print("""
                            \(newTracker.name)
                            \(newTracker.emoji)
                            \(newTracker.identifier)
                            \(newTracker.timetable)
                            \(newTracker.color)
                          """)
            } else {
                print("Не удалось создать трекер из TrackerCD")
            }
        }
        return trackersArray
    }
}
