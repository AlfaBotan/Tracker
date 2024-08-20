//
//  OnboardingPage.swift
//  Tracker
//
//  Created by Илья Волощик on 20.08.24.
//

import UIKit

enum OnboardingPage {
    case firstPage
    case secondPage

    var text: String {
        switch self {
        case .firstPage:
            return "Отслеживайте только то, что хотите"
        case .secondPage:
            return "Даже если это не литры воды и йога"
        }
    }

    var image: UIImage? {
        switch self {
        case .firstPage:
            return UIImage(named: "onboardingRed")
        case .secondPage:
            return UIImage(named: "onboardingBlue")
        }
    }
}
