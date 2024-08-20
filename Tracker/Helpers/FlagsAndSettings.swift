//
//  FlagsAndSettings.swift
//  Tracker
//
//  Created by Илья Волощик on 20.08.24.
//

import Foundation

final class FlagsAndSettings {
    let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
}
