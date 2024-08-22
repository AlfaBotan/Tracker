//
//  ViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 2.07.24.
//

import UIKit
import YandexMobileMetrica


protocol TrackerCollectionViewCellDelegate: AnyObject {
    func buttonTapped(in cell: TrackerCollectionViewCell)
    func confirmingDeletionAlert(alert: UIAlertController)
    func showEditorView(controller: UIViewController)
}

final class TrackerViewController: UIViewController {
    
    private let coreDataManager = CoreDataManager.shared
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let analyticsService = AnalyticsService()
    
    private lazy var plusButton = UIButton()
    private lazy var datePicker = UIDatePicker()
    private lazy var trackerLable = UILabel()
    private lazy var searchField = UISearchTextField()
    private lazy var placeholder = UIImageView()
    private lazy var placeholderLable = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var completedTrackers: [TrackerRecord] = []
    private var visibleTrackers: [TrackerCategory] = []
    private var filteredTrackers: [TrackerCategory] = []
    private var selectedDate: Date = Date()
    private let currentDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        coreDataManager.delegate = self
        coreDataManager.configureFetchedResultsController(for: Weekdays.fromDate(selectedDate))
        showOrHideCollection()
        filteredTrackers = visibleTrackers
        addAllSubView()
        setupToHideKeyboardOnTapOnView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }

    private func addPlusButton() {
        let plusButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(Self.plusButtonPress))
        plusButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = plusButton
    }
    
    @objc
    private func plusButtonPress() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_tracker"])
        let viewController = TrackerTypeSelectionViewController()
        present(viewController, animated: true)
    }
    
    private func addDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = .current
        datePicker.backgroundColor = .ypWhite
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
    }
    
    private func addTrackerLable() {
        let text = NSLocalizedString("trackers", comment: "Текст для trackerLable")
        trackerLable.text = text
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
        searchField.textColor = .ypColorForSearchField
        searchField.tintColor = .ypColorForSearchField
        let textForPlaceholder = NSLocalizedString("search", comment: "Текст для UITextField")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ypColorForSearchField,
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        searchField.attributedPlaceholder = NSAttributedString(string: textForPlaceholder, attributes: attributes)
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .ypColorForSearchField
        searchIcon.frame = CGRect(x: 8, y: 0, width: 16, height: 16)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
        paddingView.addSubview(searchIcon)
        searchField.leftView = paddingView
        searchField.leftViewMode = .unlessEditing
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: trackerLable.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc func textDidChange() {
        if let searchText = searchField.text, !searchText.isEmpty {
            filteredTrackers = visibleTrackers.compactMap { category in
                       // Фильтруем трекеры в категории на основе имени
                       let filteredTrackers = category.trackers.filter { tracker in
                           tracker.name.localizedCaseInsensitiveContains(searchText)
                       }
                       
                       // Если есть совпадения, возвращаем новую категорию с отфильтрованными трекерами
                       if !filteredTrackers.isEmpty {
                           return TrackerCategory(title: category.title, trackers: filteredTrackers)
                       } else {
                           return nil // Пропускаем категорию, если в ней нет совпадений
                       }
                   }
        } else {
            filteredTrackers = visibleTrackers
        }
        collectionView.reloadData()
        showOrHideCollection()
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
        let textForLable = NSLocalizedString("emptyState.title", comment: "Текст для заглушки")
        placeholderLable.text = textForLable
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
        collectionView.backgroundColor = .ypWhite
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
        view.backgroundColor = .ypWhite
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
        coreDataManager.configureFetchedResultsController(for: Weekdays.fromDate(selectedDate))
    }
    
    func getDayOfWeek(from date: Date) -> Weekdays? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { return nil }
        return Weekdays.allCases.first { $0.calendarDayNumber == weekday }
    }
    
    
    func isTrackerCompleted(_ tracker: Tracker, for date: Date) -> Bool {
        return trackerRecordStore.isTrackerCompleted(identifier: tracker.identifier, date: date)
    }
    
    private func showOrHideCollection() {
        if filteredTrackers.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredTrackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.Identifier, for: indexPath) as? TrackerCollectionViewCell
        else {
            print("Не прошёл каст")
            return UICollectionViewCell()
        }
        
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
        let categoryName = filteredTrackers[indexPath.section].title
        let completionCount2 = trackerRecordStore.getTrackerRecords(by: tracker.identifier).count
        let isCompleteToday = isTrackerCompleted(tracker, for: selectedDate)
        cell.configCell(id: tracker.identifier, name: tracker.name, color: tracker.color, emoji: tracker.emoji, completedDays: completionCount2, isEnabled: true, isCompleted: isCompleteToday, indexPath: indexPath, categoryName: categoryName, weekDays: tracker.timetable)
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
        view.titleLabel.text = filteredTrackers[indexPath.section].title
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
    func showEditorView(controller: UIViewController) {
        present(controller, animated: true)
    }
    
    func buttonTapped(in cell: TrackerCollectionViewCell) {
        
        if !Calendar.current.isDate(selectedDate, inSameDayAs: currentDate) {
            let alert = UIAlertController(title: "Ошибка", message: "Можно отмечать только текущий день", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
        
        do {
            if isTrackerCompleted(tracker, for: selectedDate) {
                trackerRecordStore.removeTrackerRecord(identifier: tracker.identifier, date: selectedDate)
            } else {
                try trackerRecordStore.addTrackerRecord(identifier: tracker.identifier, date: selectedDate)
            }
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("Ошибка при обновлении состояния трекера: \(error)")
        }
    }
    
     func confirmingDeletionAlert(alert: UIAlertController) {
            present(alert, animated: true)
        }
}

extension TrackerViewController: CoreDataManagerDelegate {
    func didChangeData(_ data: [TrackerCategory]) {
        visibleTrackers = data
        filteredTrackers = data
        textDidChange()
        showOrHideCollection()
        collectionView.reloadData()
    }
}

extension TrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
