////
////  HabitViewController.swift
////  Tracker
////
////  Created by Илья Волощик on 20.07.24.
////
//
//import UIKit
//
//protocol HabitViewControllerDelegate: AnyObject {
//    func didCreateHabitTracker(category: String, tracker: Tracker)
//}
//
//final class HabitViewController: UIViewController {
//    weak var delegate: HabitViewControllerDelegate?
//    var weekDaysArrayForTracker: [Weekdays] = []
//    var weekdaysForTracker: String {
//        var string: String = ""
//        for i in weekDaysArrayForTracker {
//            string += " \(i.shortDayName),"
//        }
//        return string
//    }
//    var textFieldIsEmpty:Bool = true
//    var categoryForTracker: String = ""
//    
//    private lazy var titleLable = UILabel()
//    private lazy var nameTrackerTextField = UITextField()
//    private lazy var habitTableView = UITableView(frame: .zero)
//    private lazy var createButton = UIButton()
//    private lazy var cancelButton = UIButton(type: .system)
//    private var rowsForTableView: [String] = ["Категория", "Расписание"]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .ypWhite
//        habitTableView.dataSource = self
//        habitTableView.delegate = self
//        configureSubviews()
//    }
//    
//    private func configureSubviews() {
//        titleLable.text = "Новая привычка"
//        titleLable.font = .systemFont(ofSize: 16, weight: .medium)
//        titleLable.textAlignment = .center
//        titleLable.textColor = .ypBlack
//        
//        nameTrackerTextField.backgroundColor = .ypBackground
//        nameTrackerTextField.layer.masksToBounds = true
//        nameTrackerTextField.layer.cornerRadius = 15
//        nameTrackerTextField.font = .systemFont(ofSize: 16, weight: .regular)
//        nameTrackerTextField.placeholder = "Введите название трекера"
//        nameTrackerTextField.textAlignment = .left
//        nameTrackerTextField.textColor = .ypBlack
//        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
//        nameTrackerTextField.leftView = leftView
//        nameTrackerTextField.leftViewMode = .always
//        nameTrackerTextField.clearButtonMode = .whileEditing
//        nameTrackerTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
//        
//        habitTableView.register(HabitAndEventTableViewСеll.self, forCellReuseIdentifier: HabitAndEventTableViewСеll.identifer)
//        habitTableView.separatorStyle = .singleLine
//        habitTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        habitTableView.layer.masksToBounds = true
//        habitTableView.layer.cornerRadius = 16
//        habitTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
//        
//        createButton.setTitle("Создать", for: .normal)
//        createButton.tintColor = .ypWhite
//        createButton.backgroundColor = .ypGray
//        createButton.layer.masksToBounds = true
//        createButton.layer.cornerRadius = 16
//        createButton.isEnabled = false
//        createButton.addTarget(self, action: #selector(createButtonIsClicked), for: .touchUpInside)
//        
//        cancelButton.setTitle("Отменить", for: .normal)
//        cancelButton.backgroundColor = .ypWhite
//        cancelButton.tintColor = .ypRed
//        cancelButton.layer.masksToBounds = true
//        cancelButton.layer.cornerRadius = 16
//        cancelButton.layer.borderWidth = 1
//        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
//        cancelButton.addTarget(self, action: #selector(cancelButtonIsClicked), for: .touchUpInside)
//        
//        titleLable.translatesAutoresizingMaskIntoConstraints = false
//        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
//        habitTableView.translatesAutoresizingMaskIntoConstraints = false
//        createButton.translatesAutoresizingMaskIntoConstraints = false
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(titleLable)
//        view.addSubview(nameTrackerTextField)
//        view.addSubview(habitTableView)
//        view.addSubview(createButton)
//        view.addSubview(cancelButton)
//        
//        NSLayoutConstraint.activate([
//            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            titleLable.heightAnchor.constraint(equalToConstant: 22),
//            
//            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
//            nameTrackerTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            nameTrackerTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            nameTrackerTextField.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 24),
//            
//            habitTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            habitTableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
//            habitTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            habitTableView.heightAnchor.constraint(equalToConstant: 150),
//            
//            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
//            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            cancelButton.heightAnchor.constraint(equalToConstant: 60),
//            cancelButton.widthAnchor.constraint(equalToConstant: 160),
//            
//            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
//            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            createButton.heightAnchor.constraint(equalToConstant: 60),
//            createButton.widthAnchor.constraint(equalToConstant: 160),
//        ])
//    }
//    
//    @objc private func editingChanged() {
//        if let text = nameTrackerTextField.text, !text.isEmpty {
//            textFieldIsEmpty = false
//            updateCreateButtonState()
//        }
//    }
//    
//    @objc private func cancelButtonIsClicked() {
//        dismiss(animated: true)
//    }
//    
//    @objc private func createButtonIsClicked() {
//        var tracker: Tracker
//        if let text = nameTrackerTextField.text {
//            dismiss(animated: true)
//            tracker = Tracker(Identifier: UUID(), name: text, color: .ypColor4, emoji: "🍄", timetable: weekDaysArrayForTracker)
//            delegate?.didCreateHabitTracker(category: categoryForTracker, tracker: tracker)
//        }
//    }
//    
//     func updateCreateButtonState() {
//        if textFieldIsEmpty == false, weekDaysArrayForTracker.isEmpty == false, categoryForTracker.isEmpty == false  {
//            createButton.isEnabled = true
//            createButton.backgroundColor = .ypBlack
//        } else {
//            createButton.isEnabled = false
//            createButton.backgroundColor = .ypGray
//        }
//    }
//}
//
//extension HabitViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
//            let viewController = CategoryViewController()
//            viewController.delegateForHabit = self
//            present(viewController, animated: true)
//        } else {
//            let viewController = WeekdaysViewController()
//            viewController.delegate = self
//            viewController.weekDaysArrayFromVC = weekDaysArrayForTracker
//            present(viewController, animated: true)
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
//
//extension HabitViewController: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        rowsForTableView.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitAndEventTableViewСеll.identifer, for: indexPath) as? HabitAndEventTableViewСеll else {
//            assertionFailure("Не удалось выполнить приведение к HabitTableViewСеll")
//            return UITableViewCell()
//        }
//        let text = rowsForTableView[indexPath.row]
//        cell.configureNameLable(textNameLable: text)
//        if indexPath.row == 0 {
//            cell.configureDescriptionLable(textDescriptionLable: categoryForTracker)
//        } else {
//            if weekDaysArrayForTracker.count == 7 {
//                cell.configureDescriptionLable(textDescriptionLable: "Каждый день")
//            } else {
//                cell.configureDescriptionLable(textDescriptionLable: weekdaysForTracker)
//            }
//        }
//        cell.backgroundColor = .ypBackground
//        updateCreateButtonState()
//        return cell
//    }
//}
//
//extension HabitViewController: CategoryViewControllerDelegateForHabit {
//    func categoryIsPicket(category: String) {
//        categoryForTracker = category
//        habitTableView.reloadData()
//    }
//}
//
//extension HabitViewController: WeekdaysViewControllerDelegate {
//    func weekdaysIsPicket(weekDaysArray: [Weekdays]) {
//        weekDaysArrayForTracker = weekDaysArray
//        habitTableView.reloadData()
//    }
//}
