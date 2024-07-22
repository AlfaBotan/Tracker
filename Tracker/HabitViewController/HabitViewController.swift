//
//  HabitViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 20.07.24.
//

import UIKit

final class HabitViewController: UIViewController {
    
    private lazy var titleLable = UILabel()
    private lazy var nameTrackerTextField = UITextField()
    private lazy var categoryAndTimetableTableView = UITableView(frame: .zero)
    private lazy var createButton = UIButton()
    private lazy var cancelButton = UIButton(type: .system)
    private var rowsForTableView: [String] = ["Категория", "Расписание"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        categoryAndTimetableTableView.dataSource = self
        categoryAndTimetableTableView.delegate = self
        configureSubviews()
    }
    
    private func configureSubviews() {
        titleLable.text = "Новая привычка"
        titleLable.font = .systemFont(ofSize: 16, weight: .medium)
        titleLable.textAlignment = .center
        titleLable.textColor = .ypBlack
        
        nameTrackerTextField.backgroundColor = .ypBackground
        nameTrackerTextField.layer.masksToBounds = true
        nameTrackerTextField.layer.cornerRadius = 15
        nameTrackerTextField.font = .systemFont(ofSize: 16, weight: .regular)
        nameTrackerTextField.placeholder = "Введите название трекера"
        nameTrackerTextField.textAlignment = .left
        nameTrackerTextField.textColor = .ypBlack
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        nameTrackerTextField.leftView = leftView
        nameTrackerTextField.leftViewMode = .always
        nameTrackerTextField.clearButtonMode = .whileEditing
        
        categoryAndTimetableTableView.register(CategoryAndTimetableTableViewСеll.self, forCellReuseIdentifier: CategoryAndTimetableTableViewСеll.identifer)
        categoryAndTimetableTableView.separatorStyle = .singleLine
        categoryAndTimetableTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        categoryAndTimetableTableView.layer.masksToBounds = true
        categoryAndTimetableTableView.layer.cornerRadius = 16
        categoryAndTimetableTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        createButton.setTitle("Создать", for: .normal)
        createButton.tintColor = .ypWhite
        createButton.backgroundColor = .ypGray
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.backgroundColor = .ypWhite
        cancelButton.tintColor = .ypRed
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonIsClicked), for: .touchUpInside)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryAndTimetableTableView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLable)
        view.addSubview(nameTrackerTextField)
        view.addSubview(categoryAndTimetableTableView)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLable.heightAnchor.constraint(equalToConstant: 22),
            
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTrackerTextField.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 24),
            
            categoryAndTimetableTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryAndTimetableTableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            categoryAndTimetableTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryAndTimetableTableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 160),
            
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 160),
        ])
    }
    
    @objc private func cancelButtonIsClicked() {
        dismiss(animated: true)
    }
}

extension HabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewController = CategoryViewController()
            present(viewController, animated: true)
        } else {
            let viewController = WeekdaysViewController()
            present(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension HabitViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryAndTimetableTableViewСеll.identifer, for: indexPath) as? CategoryAndTimetableTableViewСеll else {
            assertionFailure("Не удалось выполнить приведение к CategoryAndTimetableTableViewСеll")
            return UITableViewCell()
        }
        let text = rowsForTableView[indexPath.row]
        cell.configureCell(textLable: text)
        cell.backgroundColor = .ypBackground
        return cell
    }
    
    
}
