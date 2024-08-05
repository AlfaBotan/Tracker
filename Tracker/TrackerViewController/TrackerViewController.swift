//
//  ViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 2.07.24.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func buttonTapped(in cell: TrackerCollectionViewCell)
}

final class TrackerViewController: UIViewController {
    
    private let coreDataManager = CoreDataManager.shared
    
    private lazy var plusButton = UIButton()
    private lazy var datePicker = UIDatePicker()
    private lazy var trackerLable = UILabel()
    private lazy var searchField = UITextField()
    private lazy var placeholder = UIImageView()
    private lazy var placeholderLable = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let emojies = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
    private var mockTrackers: [TrackerCategory] = [
        TrackerCategory(title: "Спорт", trackers: [
            Tracker(identifier: UUID(), name: "Бег по утрам", color: .ypColor8, emoji: "😊", timetable: [.monday, .wednesday]),
            Tracker(identifier: UUID(), name: "Тренажёрный зал", color: .ypColor4, emoji: "🍅", timetable: [.tuesday, .thursday, .saturday])]),
        TrackerCategory(title: "Учёба", trackers: [
            Tracker(identifier: UUID(), name: "Програмирование", color: .ypColor1, emoji: "🫐", timetable: [.sunday, .monday, .tuesday])])
    ]
    
    private var completedTrackers: [TrackerRecord] = []
    private var visibleTrackers: [TrackerCategory] = []
    private var selectedDate: Date = Date()
    private let currentDate: Date = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
//        coreDataManager.removeAllTrackerRecords()
//        coreDataManager.removeAllTrackers()
//        coreDataManager.removeAllTrackerCategory()
        
        mockTrackers = coreDataManager.getTrackerCategoryFromDB()
        addAllSubView()
        filterTrackers(for: Date())
    }
    
    private func addPlusButton() {
        let image = UIImage(named: "plus1")
        plusButton.setImage(image, for: .normal)
        plusButton.tintColor = .ypBlack
        plusButton.addTarget(self, action: #selector(plusButtonPress), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
    }
    
    @objc
    private func plusButtonPress() {
        let viewController = TrackerTypeSelectionViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    private func addDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
    }
    
    private func addTrackerLable() {
        trackerLable.text = "Трекеры"
        trackerLable.font = .systemFont(ofSize: 34, weight: .bold)
        trackerLable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLable)
        
        NSLayoutConstraint.activate([
            trackerLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            trackerLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerLable.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func addSearchField() {
        searchField.backgroundColor = .ypBackground
        searchField.layer.masksToBounds = true
        searchField.layer.cornerRadius = 15
        searchField.font = .systemFont(ofSize: 17, weight: .regular)
        searchField.textAlignment = .left
        searchField.placeholder = "Поиск"
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .gray
        searchIcon.frame = CGRect(x: 8, y: 0, width: 16, height: 16)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
        paddingView.addSubview(searchIcon)
        searchField.leftView = paddingView
        searchField.leftViewMode = .unlessEditing
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: trackerLable.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func addPlaceholder() {
        placeholder.image = UIImage(named: "placeholder")
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholder)
        
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholder.widthAnchor.constraint(equalToConstant: 70),
            placeholder.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func addPlaceholderLable() {
        placeholderLable.text = "Что будем отслеживать?"
        placeholderLable.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLable.textAlignment = .center
        
        
        placeholderLable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLable)
        
        NSLayoutConstraint.activate([
            placeholderLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderLable.topAnchor.constraint(equalTo: placeholder.bottomAnchor, constant: 8),
            placeholderLable.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func addCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.Identifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addAllSubView() {
        addPlusButton()
        addDatePicker()
        addTrackerLable()
        addSearchField()
        addPlaceholder()
        addPlaceholderLable()
        addCollectionView()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        filterTrackers(for: sender.date)
    }
    
    func getDayOfWeek(from date: Date) -> Weekdays? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { return nil }
        return Weekdays.allCases.first { $0.calendarDayNumber == weekday }
    }
    
    func filterTrackers(for date: Date) {
        guard let dayOfWeek = getDayOfWeek(from: date) else { return }
        visibleTrackers = mockTrackers.map { category in
            let filteredTrackers = category.trackers.filter { $0.timetable.contains(dayOfWeek) }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        showOrHideCollection()
        collectionView.reloadData()
    }
    
    func isTrackerCompleted(_ tracker: Tracker, for date: Date) -> Bool {
        return coreDataManager.isTrackerCompleted(identifier: tracker.identifier, date: date)
    }
    
    private func showOrHideCollection() {
        if visibleTrackers.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleTrackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.Identifier, for: indexPath) as? TrackerCollectionViewCell
        else {
            print("Не прошёл каст")
            return UICollectionViewCell()
        }
        
        let tracker = visibleTrackers[indexPath.section].trackers[indexPath.row]
        
        let completionCount2 = coreDataManager.getTrackerRecords(by: tracker.identifier).count
        let isCompleteToday = isTrackerCompleted(tracker, for: selectedDate)
        print("\(isCompleteToday)")

        cell.configCell(id: tracker.identifier, name: tracker.name, color: tracker.color, emoji: tracker.emoji, completedDays: completionCount2, isEnabled: true, isCompleted: isCompleteToday, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            assertionFailure("Не удалось выполнить приведение к SupplementaryView")
            return UICollectionReusableView()
        }
        view.titleLabel.text = mockTrackers[indexPath.section].title
        return view
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Устанавливаем отступы от границ экрана до ячеек
        let leftAndRightInset: CGFloat = 16
        return UIEdgeInsets(top: 0, left: leftAndRightInset, bottom: 0, right: leftAndRightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackerViewController: TrackerCollectionViewCellDelegate {
    func buttonTapped(in cell: TrackerCollectionViewCell) {
        
        if !Calendar.current.isDate(selectedDate, inSameDayAs: currentDate) {
            let alert = UIAlertController(title: "Ошибка", message: "Можно отмечать только текущий день", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
               let tracker = visibleTrackers[indexPath.section].trackers[indexPath.row]

               do {
                   if isTrackerCompleted(tracker, for: selectedDate) {
                       // Удаление записи
                       coreDataManager.removeTrackerRecord(identifier: tracker.identifier, date: selectedDate)
                       print("Удаляем")
                   } else {
                       // Добавление записи
                       try coreDataManager.addTrackerRecord(identifier: tracker.identifier, date: selectedDate)
                       print("добавляем")
                   }
                   collectionView.reloadItems(at: [indexPath])
               } catch {
                   print("Ошибка при обновлении состояния трекера: \(error)")
               }
    }
}

extension TrackerViewController: TrackerTypeSelectionViewControllerDelegate {
    func addNewTracker(category: String, tracker: Tracker) {
        do {
            try coreDataManager.addNewTracker(tracker: tracker, categoryName: category)
        } catch {
            print("Не удалось добавить новый трекер в базу данных")
            assertionFailure(error.localizedDescription)
        }
//        if let categoryIndex = mockTrackers.firstIndex(where: { $0.title == category }) {
//            var updatedCategory = mockTrackers[categoryIndex]
//            updatedCategory = TrackerCategory(title: updatedCategory.title, trackers: updatedCategory.trackers + [tracker])
//            mockTrackers[categoryIndex] = updatedCategory
//        } else {
//            let newCategory = TrackerCategory(title: category, trackers: [tracker])
//            mockTrackers.append(newCategory)
//        }
        
        mockTrackers = coreDataManager.getTrackerCategoryFromDB()
        filterTrackers(for: selectedDate)
    }
}
