//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 3.07.24.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let trackerViewController = TrackerViewController()
        let navigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticViewController = StatisticViewController()
        trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tabBarCircle"), selectedImage: nil)
        statisticViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "tabBarRabbit"), selectedImage: nil)
        self.viewControllers = [navigationController, statisticViewController]
        addSeparatorLine()
    }
    
    private func addSeparatorLine() {
        let separator = CALayer()
        separator.frame = CGRect(x: 0, y: 0, width: tabBar.bounds.width, height: 1)
        separator.backgroundColor = UIColor.ypLightGray.cgColor
        tabBar.layer.addSublayer(separator)
    }
}
