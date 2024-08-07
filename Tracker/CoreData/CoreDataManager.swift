//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Илья Волощик on 29.07.24.
//

import UIKit
import CoreData

protocol CoreDataManagerDelegate: AnyObject {
    func didChangeData(_ data: [TrackerCategory])
}

final class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
    private override init() {}
    
    lazy var trackerStore = TrackerStore()
    lazy var trackerCategoryStore = TrackerCategoryStore()
    lazy var trackerRecordStore = TrackerRecordStore()
    lazy var uiColorMarshalling = UIColorMarshalling()
    weak var delegate: CoreDataManagerDelegate?
    
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
    private var context: NSManagedObjectContext { persistentContainer.viewContext }
    private var fetchedResultsController: NSFetchedResultsController<TrackerCD>!
    
    func configureFetchedResultsController(for weekday: String) {
        let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        fetchRequest.predicate = NSPredicate(format: "timetable CONTAINS %@", weekday)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.title", ascending: true)]
        // Если FRC ещё не был инициализирован, создаем его
        if fetchedResultsController == nil {
            print("FRC nil")
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: "category.title",
                cacheName: nil
            )
            fetchedResultsController.delegate = self
        } else {
            print("FRC not nil")
            fetchedResultsController.fetchRequest.predicate = fetchRequest.predicate
        }
        
        do {
            try fetchedResultsController.performFetch()
            print("Грузим Трекеры")
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                let trackerCategories = convertToTrackerCategories(fetchedObjects)
                delegate?.didChangeData(trackerCategories)
            }
        } catch {
            print("Ошибка выполнения запроса: \(error)")
        }
        
    }
    
    func addNewTracker(tracker: Tracker, categoryName: String) {
        // Найти или создать категорию
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
    
    func addTrackerRecord(identifier: UUID, date: Date) throws {
        let trackerRecord = TrackerRecordCD(context: context)
        trackerRecord.identifier = identifier
        trackerRecord.date = Calendar.current.startOfDay(for: date)
        try context.save()
    }
    
    func removeTrackerRecord(identifier: UUID, date: Date) {
        let fetchRequest = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
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
    
    func getTrackerRecords(by identifier: UUID) -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
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
        let fetchRequest = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
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
}

extension CoreDataManager: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        print("Will change content")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        print("Вызвался DidChangeContent")
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            let trackerCategories = convertToTrackerCategories(fetchedObjects)
            delegate?.didChangeData(trackerCategories)
        } else {
            print("Не удалось получить запрашиваемые объекты")
        }
    }
    
    private func convertToTrackerCategories(_ trackerCDs: [TrackerCD]) -> [TrackerCategory] {
        var trackerCategories: [TrackerCategory] = []
        for trackerCD in trackerCDs {
            if let tracker = createTracker(from: trackerCD) {
                if let categoryIndex = trackerCategories.firstIndex(where: { $0.title == trackerCD.category?.title }) {
                    let existingCategory = trackerCategories[categoryIndex]
                    let updatedTrackers = existingCategory.trackers + [tracker]
                    let updatedCategory = TrackerCategory(title: existingCategory.title, trackers: updatedTrackers)
                    trackerCategories[categoryIndex] = updatedCategory
                } else {
                    let newCategory = TrackerCategory(title: trackerCD.category?.title ?? "Без категории", trackers: [tracker])
                    trackerCategories.append(newCategory)
                }
            }
        }
        return trackerCategories
    }
    
    internal func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("Did change object")
    }
}

extension CoreDataManager {
    
    //MARK: Методы для отладки
    
    //    func removeAllTrackers() {
    //        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
    //        var trackersFromDB: [TrackerCD] = []
    //        do {
    //            trackersFromDB = try context.fetch(request)
    //        }  catch {
    //            print("В базе данных нет трекеров")
    //            return
    //        }
    //        for i in trackersFromDB {
    //            context.delete(i)
    //        }
    //
    //        do {
    //            try context.save()
    //        } catch {
    //            print("Не удалось удалить все записи о выполненных трекерах")
    //        }
    //    }
    
    //    func removeAllTrackerRecords() {
    //        let fetchRequest = trackerRecordStore.fetchRequest()
    //        var trackerRecordCD: [TrackerRecordCD] = []
    //        do {
    //            trackerRecordCD = try context.fetch(fetchRequest)
    //        } catch {
    //            print("В базе данных нет записей о выполненных трекерах")
    //        }
    //        for i in trackerRecordCD {
    //            context.delete(i)
    //        }
    //
    //        do {
    //            try context.save()
    //        } catch {
    //            print("Не удалось удалить все записи о выполненных трекерах")
    //        }
    //    }
    
    //    func removeAllTrackerCategory() {
    //        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
    //        var trackerCategoryFromDB: [TrackerCategoryCD] = []
    //        do {
    //            trackerCategoryFromDB = try context.fetch(request)
    //        }  catch {
    //            print("В базе данных нет трекеров")
    //            return
    //        }
    //        for i in trackerCategoryFromDB {
    //            context.delete(i)
    //        }
    //
    //        do {
    //            try context.save()
    //        } catch {
    //            print("Не удалось удалить все записи о выполненных трекерах")
    //        }
    //    }
    
    //    func getAllTrackerRecords() -> [TrackerRecord] {
    //        let fetchRequest = trackerRecordStore.fetchRequest()
    //        var trackerRecords: [TrackerRecord] = []
    //        var trackerRecordsCD: [TrackerRecordCD] = []
    //        do {
    //            trackerRecordsCD = try context.fetch(fetchRequest)
    //            for i in trackerRecordsCD {
    //                if let recordID = i.identifier, let recordDate = i.date {
    //                    trackerRecords.append(TrackerRecord(Identifier: recordID, date: recordDate))
    //                }
    //            }
    //            return trackerRecords
    //        } catch {
    //            print("Не удалось получить записи TrackerRecordCD: \(error)")
    //            return []
    //        }
    //    }
    
    //    func getTrackerCategoryFromDB() -> [TrackerCategory] {
    //        var trackerCategoryesArray: [TrackerCategory] = []
    //        let request = trackerCategoryStore.fetchRequest()
    //        var trackerCategoryesFromDB: [TrackerCategoryCD] = []
    //        do {
    //            trackerCategoryesFromDB = try context.fetch(request)
    //        }  catch {
    //            print("В базе данных нет TrackerCategoryCD")
    //            return []
    //        }
    //        for i in trackerCategoryesFromDB {
    //            if let newTrackerCategory = createTrackerCategory(from: i) {
    //                trackerCategoryesArray.append(newTrackerCategory)
    //                print("""
    //                        \(newTrackerCategory.trackers.count)
    //                        \(newTrackerCategory.title)
    //                      """)
    //            } else {
    //                print("Не удалось создать категории из TrackerCategoryCD")
    //            }
    //        }
    //        return trackerCategoryesArray
    //    }
    
    //    func getTrackersFromDB() -> [Tracker] {
    //        var trackersArray: [Tracker] = []
    //        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
    //        var trackersFromDB: [TrackerCD] = []
    //        do {
    //            trackersFromDB = try context.fetch(request)
    //        }  catch {
    //            print("В базе данных нет трекеров")
    //            return []
    //        }
    //        for i in trackersFromDB {
    //            if let newTracker = createTracker(from: i) {
    //                trackersArray.append(newTracker)
    //                print("""
    //                        \(newTracker.name)
    //                        \(newTracker.emoji)
    //                        \(newTracker.identifier)
    //                        \(newTracker.timetable)
    //                        \(newTracker.color)
    //                      """)
    //            } else {
    //                print("Не удалось создать трекер из TrackerCD")
    //            }
    //        }
    //        return trackersArray
    //    }
    
    //    func createTrackerCategory(from category: TrackerCategoryCD) -> TrackerCategory? {
    //        guard let title = category.title,
    //              let trackersCD = (category.trackers as? Set<TrackerCD>)
    //        else {return nil}
    //        var trackers: [Tracker] = []
    //        for i in trackersCD {
    //            if let trecker = createTracker(from: i) {
    //                trackers.append(trecker)
    //            }
    //        }
    //        let trackerCategoty = TrackerCategory(title: title, trackers: trackers)
    //        return trackerCategoty
    //    }
    
    //    func getTrackersForWeekday(_ weekday: String) -> [TrackerCategory] {
    //        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
    //        fetchRequest.predicate = NSPredicate(format: "timetable CONTAINS %@", weekday)
    //
    //        var trackersFromDB: [TrackerCD] = []
    //        do {
    //            trackersFromDB = try context.fetch(fetchRequest)
    //        } catch {
    //            print("Ошибка загрузки трекеров для дня недели \(weekday): \(error)")
    //            return []
    //        }
    //
    //        var trackerCategories: [TrackerCategory] = []
    //        for trackerCD in trackersFromDB {
    //            if let tracker = createTracker(from: trackerCD) {
    //                if let categoryIndex = trackerCategories.firstIndex(where: { $0.title == trackerCD.category?.title }) {
    //                    // Создаем новую структуру TrackerCategory с обновленным массивом trackers
    //                    let existingCategory = trackerCategories[categoryIndex]
    //                    let updatedTrackers = existingCategory.trackers + [tracker]
    //                    let updatedCategory = TrackerCategory(title: existingCategory.title, trackers: updatedTrackers)
    //
    //                    // Заменяем старую категорию на новую в массиве trackerCategories
    //                    trackerCategories[categoryIndex] = updatedCategory
    //                } else {
    //                    let newCategory = TrackerCategory(title: trackerCD.category?.title ?? "Без категории", trackers: [tracker])
    //                    trackerCategories.append(newCategory)
    //                }
    //            }
    //        }
    //
    //        return trackerCategories
    //    }
}
