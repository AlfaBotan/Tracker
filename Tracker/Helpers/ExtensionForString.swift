//
//  ExtensionForString.swift
//  Tracker
//
//  Created by Илья Волощик on 1.08.24.
//

import Foundation

extension String {
    func toWeekdaysArray() -> [Weekdays] {
        return self.split(separator: ",").compactMap { Weekdays(rawValue: String($0)) }
    }
}
