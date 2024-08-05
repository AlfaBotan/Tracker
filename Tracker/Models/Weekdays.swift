//
//  Weekdays.swift
//  Tracker
//
//  Created by Илья Волощик on 15.07.24.
//

import Foundation

enum Weekdays: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var calendarDayNumber: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    var shortDayName: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
}

extension Weekdays {
    static func fromDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        
        switch weekdayNumber {
        case 1: return Weekdays.sunday.rawValue
        case 2: return Weekdays.monday.rawValue
        case 3: return Weekdays.tuesday.rawValue
        case 4: return Weekdays.wednesday.rawValue
        case 5: return Weekdays.thursday.rawValue
        case 6: return Weekdays.friday.rawValue
        case 7: return Weekdays.saturday.rawValue
        default: return Weekdays.sunday.rawValue // на случай, если что-то пойдет не так
        }
    }
}
