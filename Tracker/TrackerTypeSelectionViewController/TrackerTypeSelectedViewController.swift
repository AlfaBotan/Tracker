//
//  TypeSelected.swift
//  Tracker
//
//  Created by Илья Волощик on 24.07.24.
//

import UIKit

protocol TrackerTypeSelectionViewControllerDelegate: AnyObject {
    func addNewTracker(category: String, tracker: Tracker)
}

final class TrackerTypeSelectionViewController: UIViewController {
    weak var delegate: TrackerTypeSelectionViewControllerDelegate?
    private lazy var titleLabel = UILabel()
    private lazy var habitButton = UIButton()
    private lazy var eventButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureSubviews()
    }

    private func configureSubviews() {
        titleLabel.text = "Создание трекера"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .ypBlack

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
        eventButton.addTarget(self, action: #selector(eventButtonPress), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        eventButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(eventButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),

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

    @objc private func habitButtonPress() {
        let viewController = HabitAndEventViewController()
        viewController.trackerType = .habit
        viewController.delegate = self
        present(viewController, animated: true)
    }

    @objc private func eventButtonPress() {
        let viewController = HabitAndEventViewController()
        viewController.trackerType = .event
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

extension TrackerTypeSelectionViewController: HabitAndEventViewControllerDelegate {
    func didCreateTracker(category: String, tracker: Tracker) {
        delegate?.addNewTracker(category: category, tracker: tracker)
        dismiss(animated: true)
    }
}
