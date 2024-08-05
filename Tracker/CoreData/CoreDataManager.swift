//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Илья Волощик on 29.07.24.
//

import UIKit
import CoreData

final class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
    private override init() {}
    
    lazy var trackerStore = TrackerStore()
    lazy var trackerCategoryStore = TrackerCategoryStore()
    lazy var trackerRecordStore = TrackerRecordStore()
    lazy var uiColorMarshalling = UIColorMarshalling()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCD>!
    
    func configureFetchedResultsController(request: NSFetchRequest<TrackerCD>) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        //        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка!!! \(error.localizedDescription)")
        }
    }
    
    func addNewTracker(tracker: Tracker, categoryName: String) throws {
        // Найти или создать категорию
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        
        let categories = try context.fetch(fetchRequest)
        let category: TrackerCategoryCD
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            category = TrackerCategoryCD(context: context)
            category.title = categoryName
        }
        
        // Создать новый трекер и установить его свойства
        let trackerForDB = TrackerCD(context: context)
        trackerForDB.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerForDB.emoji = tracker.emoji
        trackerForDB.identifier = tracker.identifier
        trackerForDB.timetable = tracker.timetable.toString()
        trackerForDB.name = tracker.name
        
        // Установить отношение между трекером и категорией
        trackerForDB.category = category
        category.addToTrackers(trackerForDB)
        
        // Сохранить контекст
        try context.save()
    }
    
    func removeAllTrackers() {
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
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
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
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
    
    func getTrackerCategoryFromDB() -> [TrackerCategory] {
        var trackerCategoryesArray: [TrackerCategory] = []
        let request = trackerCategoryStore.fetchRequest()
        var trackerCategoryesFromDB: [TrackerCategoryCD] = []
        do {
            trackerCategoryesFromDB = try context.fetch(request)
        }  catch {
            print("В базе данных нет TrackerCategoryCD")
            return []
        }
        for i in trackerCategoryesFromDB {
            if let newTrackerCategory = createTrackerCategory(from: i) {
                trackerCategoryesArray.append(newTrackerCategory)
                print("""
                        \(newTrackerCategory.trackers.count)
                        \(newTrackerCategory.title)
                      """)
            } else {
                print("Не удалось создать категории из TrackerCategoryCD")
            }
        }
        return trackerCategoryesArray
    }
    
    func createTracker(from trackerCD: TrackerCD) -> Tracker? {
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
    
    func createTrackerCategory(from category: TrackerCategoryCD) -> TrackerCategory? {
        guard let title = category.title,
              let trackersCD = (category.trackers as? Set<TrackerCD>)
        else {return nil}
        var trackers: [Tracker] = []
        for i in trackersCD {
            if let trecker = createTracker(from: i) {
                trackers.append(trecker)
            }
        }
        let trackerCategoty = TrackerCategory(title: title, trackers: trackers)
        return trackerCategoty
    }
    
    func removeAllTrackerCategory() {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        var trackerCategoryFromDB: [TrackerCategoryCD] = []
        do {
            trackerCategoryFromDB = try context.fetch(request)
        }  catch {
            print("В базе данных нет трекеров")
            return
        }
        for i in trackerCategoryFromDB {
            context.delete(i)
        }
        
        do {
            try context.save()
        } catch {
            print("Не удалось удалить все записи о выполненных трекерах")
        }
    }

    
    func createAndAddTrackerRecordCD(from record: TrackerRecord) {
        let trackerRecord = TrackerRecordCD(context: context)
        trackerRecord.date = record.date
        trackerRecord.identifier = record.Identifier
        do {
            try context.save()
        } catch {
            print("не удалось сохранить TrackerRecordCD")
            print(error.localizedDescription)
        }
    }
    
    func addTrackerRecord(identifier: UUID, date: Date) throws {
            let trackerRecord = TrackerRecordCD(context: context)
            trackerRecord.identifier = identifier
            trackerRecord.date = Calendar.current.startOfDay(for: date)
            try context.save()
        }
    
    func removeTrackerRecord(identifier: UUID, date: Date) {
            let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
            let startOfDay = Calendar.current.startOfDay(for: date)
            
            fetchRequest.predicate = NSPredicate(format: "identifier == %@ AND date == %@", identifier as CVarArg, startOfDay as NSDate)
            
            do {
                let records = try context.fetch(fetchRequest)
                for record in records {
                    context.delete(record)
                }
                try context.save()
            } catch {
                print("Не удалось удалить запись трекера: \(error)")
            }
        }
    
    func removeAllTrackerRecords() {
        let fetchRequest = trackerRecordStore.fetchRequest()
        var trackerRecordCD: [TrackerRecordCD] = []
        do {
           trackerRecordCD = try context.fetch(fetchRequest)
        } catch {
            print("В базе данных нет записей о выполненных трекерах")
        }
        for i in trackerRecordCD {
            context.delete(i)
        }
        
        do {
            try context.save()
        } catch {
            print("Не удалось удалить все записи о выполненных трекерах")
        }
    }
    
    func getTrackerRecords(by identifier: UUID) -> [TrackerRecord] {
        let fetchRequest = trackerRecordStore.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        var trackerRecords: [TrackerRecord] = []
        var trackerRecordsCD: [TrackerRecordCD] = []
            do {
                trackerRecordsCD = try context.fetch(fetchRequest)
                for i in trackerRecordsCD {
                    if let recordID = i.identifier, let recordDate = i.date {
                        trackerRecords.append(TrackerRecord(Identifier: recordID, date: recordDate))
                    }
                }
                return trackerRecords
            } catch {
                print("Не удалось получить записи TrackerRecordCD: \(error)")
                return []
            }
        }
    
    func isTrackerCompleted(identifier: UUID, date: Date) -> Bool {
            let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
            let startOfDay = Calendar.current.startOfDay(for: date)

            fetchRequest.predicate = NSPredicate(format: "identifier == %@ AND date == %@", identifier as CVarArg, startOfDay as NSDate)

            do {
                let count = try context.count(for: fetchRequest)
                return count > 0
            } catch {
                print("Не удалось проверить завершенность трекера: \(error)")
                return false
            }
        }
    
    
    func getAllTrackerRecords() -> [TrackerRecord] {
        let fetchRequest = trackerRecordStore.fetchRequest()
        var trackerRecords: [TrackerRecord] = []
        var trackerRecordsCD: [TrackerRecordCD] = []
            do {
                trackerRecordsCD = try context.fetch(fetchRequest)
                for i in trackerRecordsCD {
                    if let recordID = i.identifier, let recordDate = i.date {
                        trackerRecords.append(TrackerRecord(Identifier: recordID, date: recordDate))
                    }
                }
                return trackerRecords
            } catch {
                print("Не удалось получить записи TrackerRecordCD: \(error)")
                return []
            }
        }
}

extension CoreDataManager: NSFetchedResultsControllerDelegate {
    
}
