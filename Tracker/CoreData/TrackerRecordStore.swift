//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Илья Волощик on 30.07.24.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

   private func fetchRequest() -> NSFetchRequest<TrackerRecordCD> {
        return NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
    }
    
    func addTrackerRecord(identifier: UUID, date: Date) throws {
        let trackerRecord = TrackerRecordCD(context: context)
        trackerRecord.identifier = identifier
        trackerRecord.date = Calendar.current.startOfDay(for: date)
        try context.save()
    }
    
    func removeTrackerRecord(identifier: UUID, date: Date) {
        let fetchRequest = fetchRequest()
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
        let fetchRequest = fetchRequest()
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
        let fetchRequest = fetchRequest()
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
    
        func removeAllTrackerRecords() {
            let fetchRequest = fetchRequest()
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
    
        func getAllTrackerRecords() -> [TrackerRecord] {
            let fetchRequest = fetchRequest()
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
