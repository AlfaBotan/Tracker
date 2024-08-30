//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 3.07.24.
//

import UIKit

final class TabBarViewController: UITabBarController {
    let nameForTrackers = NSLocalizedString("trackers", comment: "Название вкладки трекеров")
    let nameForStatistics = NSLocalizedString("statistics", comment: "Название вкладки статистики")
    private var separator: CALayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .ypWhite
        let trackerViewController = TrackerViewController()
        let navigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticViewController = StatisticViewController()
        trackerViewController.tabBarItem = UITabBarItem(title: nameForTrackers, image: UIImage(named: "tabBarCircle"), selectedImage: nil)
        trackerViewController.delegate = statisticViewController
        statisticViewController.tabBarItem = UITabBarItem(title: nameForStatistics, image: UIImage(named: "tabBarRabbit"), selectedImage: nil)
        self.viewControllers = [navigationController, statisticViewController]
        addSeparatorLine()
    }
    
    private func addSeparatorLine() {
        if separator == nil {
            separator = CALayer()
            separator?.frame = CGRect(x: 0, y: 0, width: tabBar.bounds.width, height: 1)
            tabBar.layer.addSublayer(separator!)
        }
        separator?.backgroundColor = UIColor.ypSeparatorForTabBar.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            addSeparatorLine()
        }
    }
}
