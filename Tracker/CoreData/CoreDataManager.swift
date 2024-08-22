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
                pinCategory(array: trackerCategories)
            }
        } catch {
            print("Ошибка выполнения запроса: \(error)")
        }
    }
    
    func configureFetchedResultsController(for identifiers: [UUID]) {
        let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        
        // Создаем NSPredicate для фильтрации по массиву идентификаторов
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        
        // Задаем сортировку (если нужно, можно изменить ключ сортировки)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.title", ascending: true)]
        
        // Настраиваем или обновляем fetchedResultsController
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
        
        // Выполняем запрос
        do {
            try fetchedResultsController.performFetch()
            print("Грузим Трекеры")
            
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                let trackerCategories = convertToTrackerCategories(fetchedObjects)
                pinCategory(array: trackerCategories)
            }
        } catch {
            print("Ошибка выполнения запроса: \(error)")
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
    
    func pinCategory(array: [TrackerCategory]) {
        if let pinnedIndex = array.firstIndex(where: { $0.title == "Закрепленные" }) {
            var updatedCategories = array
            let pinnedCategory = updatedCategories.remove(at: pinnedIndex)
            updatedCategories.insert(pinnedCategory, at: 0)
            delegate?.didChangeData(updatedCategories)
        } else {
            delegate?.didChangeData(array)
        }
    }
}
    


extension CoreDataManager: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            let trackerCategories = convertToTrackerCategories(fetchedObjects)
            pinCategory(array: trackerCategories)
        } else {
            print("Не удалось получить запрашиваемые объекты")
        }
    }
}
