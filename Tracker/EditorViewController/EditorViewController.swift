//
//  EditorViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 22.08.24.
//

import UIKit

final class EditorViewController: UIViewController {
    enum TrackerType {
        case habit
        case event
    }
    private let marshalling = UIColorMarshalling()
    private let trackerStore = TrackerStore()
    var trackerType: TrackerType = .habit
    
    var coudDays: Int = 0
    var id: UUID? = nil
    var selectedEmojiIndexPath: IndexPath?
    var selectedColorIndexPath: IndexPath?
    var colorForTracer: UIColor?
    var emojiForTracker: String?
    var weekDaysArrayForTracker: [Weekdays] = []
    var textFieldIsEmpty: Bool = false
    var nameForTracker: String = ""
    var categoryForTracker: String = ""
    var weekdaysForTracker: String {
        var string: String = ""
        for i in weekDaysArrayForTracker {
            string += " \(i.shortDayName),"
        }
        return string
    }
    private let emojies = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥦", "🧄", "🧅", "🍄"]
    private let colors: [UIColor] = [UIColor(resource: .ypColor1), UIColor(resource: .ypColor2), UIColor(resource: .ypColor3), UIColor(resource: .ypColor4), UIColor(resource: .ypColor5), UIColor(resource: .ypColor6), UIColor(resource: .ypColor7), UIColor(resource: .ypColor8), UIColor(resource: .ypColor9), UIColor(resource: .ypColor10), UIColor(resource: .ypColor11), UIColor(resource: .ypColor12), UIColor(resource: .ypColor13), UIColor(resource: .ypColor14), UIColor(resource: .ypColor15), UIColor(resource: .ypColor16), UIColor(resource: .ypColor17), UIColor(resource: .ypColor18)]
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var countDaysLable = UILabel()
    private lazy var nameTrackerTextField = UITextField()
    private lazy var trackerTableView = UITableView(frame: .zero)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var createButton = UIButton()
    private lazy var cancelButton = UIButton(type: .system)
    
    private var rowsForTableView: [String] {
        return trackerType == .habit ? ["Категория", "Расписание"] : ["Категория"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        trackerTableView.dataSource = self
        trackerTableView.delegate = self
        configureSubviews()
        setupToHideKeyboardOnTapOnView()
    }
    
    func configureSubviews() {
        scrollView.alwaysBounceVertical = true
        titleLabel.text = trackerType == .habit ? "Редактирование привычки" : "Редактирование события"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .ypBlack
        
        countDaysLable.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: "подбор формы записи дня"),
            coudDays
        )
        countDaysLable.font = .systemFont(ofSize: 32, weight: .bold)
        countDaysLable.textAlignment = .center
        
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
        nameTrackerTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        nameTrackerTextField.delegate = self
        nameTrackerTextField.text = nameForTracker
        
        trackerTableView.register(HabitAndEventTableViewСеll.self, forCellReuseIdentifier: HabitAndEventTableViewСеll.identifer)
        trackerTableView.separatorStyle = .singleLine
        trackerTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackerTableView.layer.masksToBounds = true
        trackerTableView.layer.cornerRadius = 16
        trackerTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HabitAndEventCollectionViewCell.self, forCellWithReuseIdentifier: HabitAndEventCollectionViewCell.Identifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        
        createButton.setTitle("Сохранить", for: .normal)
        createButton.tintColor = .ypWhite
        createButton.backgroundColor = .ypGray
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonIsClicked), for: .touchUpInside)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.backgroundColor = .ypWhite
        cancelButton.tintColor = .ypRed
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonIsClicked), for: .touchUpInside)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countDaysLable.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        trackerTableView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(countDaysLable)
        contentView.addSubview(nameTrackerTextField)
        contentView.addSubview(trackerTableView)
        contentView.addSubview(collectionView)
        contentView.addSubview(createButton)
        contentView.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            countDaysLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            countDaysLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            countDaysLable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            countDaysLable.heightAnchor.constraint(equalToConstant: 40),
            
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTrackerTextField.topAnchor.constraint(equalTo: countDaysLable.bottomAnchor, constant: 24),
            
            trackerTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerTableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            trackerTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerTableView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? 150 : 75),
            
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: trackerTableView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 700),
            
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 160),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 160),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc private func editingChanged() {
        if let text = nameTrackerTextField.text, !text.isEmpty {
            textFieldIsEmpty = false
        }
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonIsClicked() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonIsClicked() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        guard let color = colorForTracer, let emoji = emojiForTracker else {return}
        var tracker: Tracker
        if let text = nameTrackerTextField.text {
            if trackerType == .habit {
                tracker = Tracker(identifier: UUID(), name: text, color: color, emoji: emoji, timetable: weekDaysArrayForTracker)
            } else {
                weekDaysArrayForTracker = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                tracker = Tracker(identifier: UUID(), name: text, color: color, emoji: emoji, timetable: weekDaysArrayForTracker)
            }
            trackerStore.addNewTracker(tracker: tracker, categoryName: categoryForTracker)
            trackerStore.deleteTracker(id: id!)
        }
    }
    
    func pickedEmojiAndColor(emoji: String, color: UIColor) {
        guard let emojiIndex = emojies.firstIndex(of: emoji) else {
            print("Не удалось найти emoji в массиве")
            return
        }
        
        let convertedColor1 = marshalling.hexString(from: color)
        let convertedArray = colors.map { color in
            marshalling.hexString(from: color)
        }

        guard  let colorIndex = convertedArray.firstIndex(of: convertedColor1) else {
            print("Не удалось найти цвет в массиве")
            return
        }
        
        selectedEmojiIndexPath = IndexPath(row: emojiIndex, section: 0)
        selectedColorIndexPath = IndexPath(row: colorIndex, section: 1)
        colorForTracer = colors[colorIndex]
        emojiForTracker = emojies[emojiIndex]
    }
    
    internal func updateCreateButtonState() {
        if textFieldIsEmpty == false, (trackerType == .event || !weekDaysArrayForTracker.isEmpty), !categoryForTracker.isEmpty, colorForTracer != nil, emojiForTracker != nil {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
}
//MARK: UITextFieldDelegate
extension EditorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

//MARK: UITableViewDelegate
extension EditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewModel = CategoryViewModel()
            viewModel.delegate = self
            let viewController = CategoryViewController(categoryViewModel: viewModel)
            present(viewController, animated: true)
        } else if trackerType == .habit && indexPath.row == 1 {
            let viewController = WeekdaysViewController()
            viewController.delegate = self
            viewController.weekDaysArrayFromVC = weekDaysArrayForTracker
            present(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: UITableViewDataSource

extension EditorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitAndEventTableViewСеll.identifer, for: indexPath) as? HabitAndEventTableViewСеll else {
            assertionFailure("Не удалось выполнить приведение к EventAndHabitTableViewСеll")
            return UITableViewCell()
        }
        let text = rowsForTableView[indexPath.row]
        cell.configureNameLable(textNameLable: text)
        if indexPath.row == 0 {
            cell.configureDescriptionLable(textDescriptionLable: categoryForTracker)
        } else if trackerType == .habit && indexPath.row == 1 {
            if weekDaysArrayForTracker.count == 7 {
                cell.configureDescriptionLable(textDescriptionLable: "Каждый день")
            } else {
                cell.configureDescriptionLable(textDescriptionLable: weekdaysForTracker)
            }
        }
        cell.backgroundColor = .ypBackground
        return cell
    }
}

//MARK: UICollectionViewDataSource

extension EditorViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojies.count
        } else if section == 1 {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitAndEventCollectionViewCell.Identifier, for: indexPath) as? HabitAndEventCollectionViewCell
        else {
            print("Не прошёл каст к HabitAndEventCollectionViewCell")
            return UICollectionViewCell()
        }
        
        cell.reset()
        if indexPath.section == 0 {
            cell.configEmojiCell(emoji: emojies[indexPath.row])
            
            if indexPath == selectedEmojiIndexPath {
                cell.selectEmoji()
            } else {
                cell.deselectEmoji()
            }
            
        } else if indexPath.section == 1 {
            cell.configColorCell(color: colors[indexPath.row])
            if indexPath == selectedColorIndexPath {
                let colorForBorder = colors[indexPath.row].withAlphaComponent(0.3)
                cell.selectColor(color: colorForBorder)
            } else {
                cell.deselectColor()
            }
        }
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
        if indexPath.section == 0 {
            view.titleLabel.text = "Emoji"
        } else {
            view.titleLabel.text = "Цвет"
        }
        return view
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension EditorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Устанавливаем отступы от границ экрана до ячеек
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
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

extension EditorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if let selectedEmojiIndexPath = selectedEmojiIndexPath, let previousCell = collectionView.cellForItem(at: selectedEmojiIndexPath) as? HabitAndEventCollectionViewCell {
                previousCell.deselectEmoji()
            }
            selectedEmojiIndexPath = indexPath
            emojiForTracker = emojies[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? HabitAndEventCollectionViewCell {
                cell.selectEmoji()
            }
        }
        else if indexPath.section == 1 {
            if let selectedColorIndexPath = selectedColorIndexPath, let previousCell = collectionView.cellForItem(at: selectedColorIndexPath) as? HabitAndEventCollectionViewCell {
                previousCell.deselectColor()
            }
            selectedColorIndexPath = indexPath
            colorForTracer = colors[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? HabitAndEventCollectionViewCell {
                let colorForBorder = colors[indexPath.row].withAlphaComponent(0.3)
                cell.selectColor(color: colorForBorder)
            }
        }
        updateCreateButtonState()
    }
}

extension EditorViewController: CategoryViewModelDelegate {
    func categoryIsPicked(category: String) {
        categoryForTracker = category
        trackerTableView.reloadData()
        updateCreateButtonState()
    }
}

extension EditorViewController: WeekdaysViewControllerDelegate {
    func weekdaysIsPicket(weekDaysArray: [Weekdays]) {
        weekDaysArrayForTracker = weekDaysArray
        trackerTableView.reloadData()
        updateCreateButtonState()
    }
}

