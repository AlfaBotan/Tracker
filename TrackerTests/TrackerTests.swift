//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Илья Волощик on 21.08.24.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testTrackerViewControllerForEmptyState() {
        let testVC = TrackerViewController()
        let coreDataManager = CoreDataManager.shared
        coreDataManager.trackerCategoryStore.removeAllTrackerCategory()
        coreDataManager.trackerStore.removeAllTrackers()
        coreDataManager.trackerRecordStore.removeAllTrackerRecords()
        assertSnapshot(of: testVC, as: .image)
    }
    
    func testTrackerViewControllerForNormalState() {
        let testVC = TrackerViewController()
        let coreDataManager = CoreDataManager.shared
        coreDataManager.trackerCategoryStore.removeAllTrackerCategory()
        coreDataManager.trackerStore.removeAllTrackers()
        coreDataManager.trackerRecordStore.removeAllTrackerRecords()
        coreDataManager.trackerStore.addNewTracker(tracker: Tracker(identifier: UUID(), name: "Бег по утрам", color: .ypColor1, emoji: "🍊", timetable: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]), categoryName: "Спорт")
        assertSnapshot(of: testVC, as: .image)
    }
}
