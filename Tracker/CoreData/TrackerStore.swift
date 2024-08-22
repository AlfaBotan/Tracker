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
            } else {
                print("Не удалось создать трекер из TrackerCD")
            }
        }
        return trackersArray
    }
    
    func deleteTracker(id: UUID) {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(request).first {
                context.delete(tracker)
                try context.save()
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
    
    func pinTracker(id: UUID) {
        let categoryName = "Закрепленные"
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
        
        let request = self.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(request).first {
                tracker.originalCategory = tracker.category?.title
                tracker.category = category
                category.addToTrackers(tracker)
                try context.save()
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
    
    func unpinTracker(id: UUID) {
        let request = self.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", id as CVarArg)
        do {
            if let tracker = try context.fetch(request).first {
                
                tracker.category?.removeFromTrackers(tracker)
                
                if let originalCategory = tracker.originalCategory {
                    
                    let fetchRequest = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
                    fetchRequest.predicate = NSPredicate(format: "title == %@", originalCategory)
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
                        category.title = originalCategory
                    }
                    category.addToTrackers(tracker)
                }
            }
        } catch {
            print("Не удалось найти трекер по ID")
        }
    }
    
}
