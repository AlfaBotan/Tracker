//
//  FiltersCases.swift
//  Tracker
//
//  Created by Илья Волощик on 22.08.24.
//

import Foundation

enum FiltersCases: String {
    case allTrackers = "AllTrackers"
    case trackersOnToday = "TrackersOnToday"
    case completedTrackers = "CompletedTrackers"
    case unCompletedTrackers = "UnCompletedTrackers"
    
    var text: String {
        switch self {
        case .allTrackers:
            return "Все трекеры"
        case .trackersOnToday:
            return "Трекеры на сегодня"
        case .completedTrackers:
            return "Завершенные"
        case .unCompletedTrackers:
            return "Не завершенные"
        }
    }
}
