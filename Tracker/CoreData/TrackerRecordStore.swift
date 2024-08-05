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

    func fetchRequest() -> NSFetchRequest<TrackerRecordCD> {
        return NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
    }
}
