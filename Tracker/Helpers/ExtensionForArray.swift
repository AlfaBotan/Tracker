//
//  ExtensionForArray.swift
//  Tracker
//
//  Created by Илья Волощик on 1.08.24.
//

import Foundation

extension Array where Element == Weekdays {
    func toString() -> String {
        return self.map { $0.rawValue }.joined(separator: ",")
    }
}
