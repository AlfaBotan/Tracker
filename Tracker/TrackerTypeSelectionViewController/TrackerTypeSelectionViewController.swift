//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 20.07.24.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    private lazy var titleLable = UILabel()
    private lazy var habitButton = UIButton()
    private lazy var eventButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureSubviews()
    }
    
    private func configureSubviews() {
        titleLable.text = "Создание трекера"
        titleLable.font = .systemFont(ofSize: 16, weight: .medium)
        titleLable.textAlignment = .center
        titleLable.textColor = .ypBlack
        
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.backgroundColor = .ypBlack
        habitButton.tintColor = .ypWhite
        habitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        habitButton.layer.cornerRadius = 16
        habitButton.layer.masksToBounds = true
        habitButton.addTarget(self, action: #selector(habitButtonPress), for: .touchUpInside)
        
        eventButton.setTitle("Нерегулярное событие", for: .normal)
        eventButton.backgroundColor = .ypBlack
        eventButton.tintColor = .ypWhite
        eventButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        eventButton.layer.cornerRadius = 16
        eventButton.layer.masksToBounds = true
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLable)
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLable.heightAnchor.constraint(equalToConstant: 22),
            
            habitButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
        ])
    }
    
    @objc
    private func habitButtonPress() {
        let viewController = HabitViewController()
        present(viewController, animated: true)
    }
}
