////
////  EventViewController.swift
////  Tracker
////
////  Created by Илья Волощик on 22.07.24.
////
//
//import UIKit
//
//protocol EventViewControllerDelegate: AnyObject {
//    func didCreateEventTracker(category: String, tracker: Tracker)
//}
//
//final class EventViewController: UIViewController {
//    weak var delegate: EventViewControllerDelegate?
//    var textFieldIsEmpty:Bool = true
//    var categoryForTracker: String = ""
//    
//    private lazy var titleLable = UILabel()
//    private lazy var nameTrackerTextField = UITextField()
//    private lazy var eventTableView = UITableView(frame: .zero)
//    private lazy var createButton = UIButton()
//    private lazy var cancelButton = UIButton(type: .system)
//    private var rowsForTableView: [String] = ["Категория"]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .ypWhite
//        eventTableView.delegate = self
//        eventTableView.dataSource = self
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
//        eventTableView.register(HabitAndEventTableViewСеll.self, forCellReuseIdentifier: HabitAndEventTableViewСеll.identifer)
//        eventTableView.separatorStyle = .singleLine
//        eventTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        eventTableView.layer.masksToBounds = true
//        eventTableView.layer.cornerRadius = 16
//        eventTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
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
//        eventTableView.translatesAutoresizingMaskIntoConstraints = false
//        createButton.translatesAutoresizingMaskIntoConstraints = false
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(titleLable)
//        view.addSubview(nameTrackerTextField)
//        view.addSubview(eventTableView)
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
//            eventTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            eventTableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
//            eventTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            eventTableView.heightAnchor.constraint(equalToConstant: 75),
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
//            activateCreateButton()
//        }
//    }
//    
//    @objc private func cancelButtonIsClicked() {
//        dismiss(animated: true)
//    }
//    
//    @objc private func createButtonIsClicked() {
//        let weekDaysArrayForTracker: [Weekdays] = [Weekdays.monday, Weekdays.tuesday, Weekdays.wednesday, Weekdays.thursday, Weekdays.friday, Weekdays.saturday, Weekdays.sunday]
//        let tracker = Tracker(Identifier: UUID(), name: nameTrackerTextField.text!, color: .ypColor4, emoji: "🍄", timetable: weekDaysArrayForTracker)
//        delegate?.didCreateEventTracker(category: categoryForTracker, tracker: tracker)
//        dismiss(animated: true)
//    }
//    
//    private func activateCreateButton() {
//        if textFieldIsEmpty == false, categoryForTracker.isEmpty == false  {
//            createButton.isEnabled = true
//            createButton.backgroundColor = .ypBlack
//        }
//    }
//}
//
//extension EventViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let viewController = CategoryViewController()
//        viewController.delegateForEvent = self
//        present(viewController, animated: true)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
//
//extension EventViewController: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        rowsForTableView.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitAndEventTableViewСеll.identifer, for: indexPath) as? HabitAndEventTableViewСеll else {
//            assertionFailure("Не удалось выполнить приведение к EventTableViewСеll")
//            return UITableViewCell()
//        }
//        let text = rowsForTableView[indexPath.row]
//        cell.configureNameLable(textNameLable: text)
//        cell.configureDescriptionLable(textDescriptionLable: categoryForTracker)
//        
//        cell.backgroundColor = .ypBackground
//        return cell
//    }
//}
//
//extension EventViewController: CategoryViewControllerDelegateForEvent {
//    func categoryIsPicket(category: String) {
//        categoryForTracker = category
//        eventTableView.reloadData()
//    }
//}
