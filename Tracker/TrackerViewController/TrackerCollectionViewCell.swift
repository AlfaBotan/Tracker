//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Илья Волощик on 14.07.24.
//

import UIKit
import YandexMobileMetrica

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    private let coreDataManager = CoreDataManager.shared
    private let trackerStore = TrackerStore()
    static let Identifier = "TrackerCollectionViewCell"
    private let analyticsService = AnalyticsService()
    
    private lazy var topView = UIView()
    private lazy var smileLabel = UILabel()
    private lazy var descriptionLAble = UILabel()
    private lazy var countDaysLable = UILabel()
    private lazy var plusButton = UIButton()
    
    private var indexPath: IndexPath?
    private var countDays: Int = 0
    private var trackerId: UUID? = nil
    private var isCompleted: Bool = false
    private var categoryName: String = ""
    private var weekDays: [Weekdays] = []
    private var color: UIColor? = nil
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewsAndConstraints()
        setupContextMenuInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        topView.addInteraction(interaction)
    }
    
    private func addSubviewsAndConstraints() {
        
        
        topView.layer.masksToBounds = true
        topView.layer.cornerRadius = 16
        
        smileLabel.backgroundColor = .ypBackForSmile
        smileLabel.layer.masksToBounds = true
        smileLabel.layer.cornerRadius = 12
        smileLabel.textAlignment = .center
        smileLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        descriptionLAble.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLAble.textColor = .ypWhite
        
        countDaysLable.font = .systemFont(ofSize: 12, weight: .medium)
        countDaysLable.textColor = .ypBlack
        
        
        plusButton.layer.cornerRadius = 17
        plusButton.layer.masksToBounds = true
        plusButton.tintColor = .ypWhite
        plusButton.addTarget(self, action: #selector(plusButtonPress), for: .touchUpInside)
        
        
        descriptionLAble.translatesAutoresizingMaskIntoConstraints = false
        smileLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        countDaysLable.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(topView)
        topView.addSubview(smileLabel)
        topView.addSubview(descriptionLAble)
        contentView.addSubview(countDaysLable)
        contentView.addSubview(plusButton)
        
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 90),
        ])
        
        NSLayoutConstraint.activate([
            smileLabel.heightAnchor.constraint(equalToConstant: 24),
            smileLabel.widthAnchor.constraint(equalToConstant: 24),
            smileLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 12),
            smileLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            
            descriptionLAble.heightAnchor.constraint(equalToConstant: 34),
            descriptionLAble.widthAnchor.constraint(equalToConstant: 143),
            descriptionLAble.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 44),
            descriptionLAble.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            
            countDaysLable.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            countDaysLable.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16),
            countDaysLable.heightAnchor.constraint(equalToConstant: 18),
            countDaysLable.widthAnchor.constraint(equalToConstant: 100),
            
            plusButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 8),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc
    private func plusButtonPress() {
        delegate?.buttonTapped(in: self)
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "plus_on_trackerCard"])
    }
    
    func configCell(id: UUID,
                    name: String,
                    color: UIColor,
                    emoji: String,
                    completedDays: Int,
                    isEnabled: Bool,
                    isCompleted: Bool,
                    indexPath: IndexPath,
                    categoryName: String,
                    weekDays: [Weekdays]){
        topView.backgroundColor = color
        plusButton.backgroundColor = color
        plusButton.alpha = isCompleted ? 0.3 : 1
        if isCompleted {
            plusButton.setImage(UIImage(named: "done"), for: .normal)
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        descriptionLAble.text = name
        smileLabel.text = emoji
        countDaysLable.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: "подбор формы записи дня"),
            completedDays
        )
        
        self.indexPath = indexPath
        self.trackerId = id
        self.categoryName = categoryName
        self.isCompleted = isCompleted
        self.weekDays = weekDays
        self.color = color
        self.countDays = completedDays
    }
    
    func pinOrUnPinTracker(category: String) -> UIAction {
        if category == "Закрепленные" {
            return UIAction(title: "Открепить") { [weak self] _ in
                guard let self = self else {return}
                self.trackerStore.unpinTracker(id: self.trackerId!)
            }
        } else {
            return UIAction(title: "Закрепить") { [weak self] _ in
                guard let self = self else {return}
                self.trackerStore.pinTracker(id: self.trackerId!)
            }
        }
    }
}

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let deleteCellString = NSLocalizedString("delete", comment: "text for contextMenu")
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return UIMenu(children: [
                self.pinOrUnPinTracker(category: self.categoryName),
                UIAction(title: "Редактировать", handler: { [weak self] _ in
                    guard let self = self else {return}
                    self.analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
                    self.editFlow(self: self)
                }),
                UIAction(title: deleteCellString, attributes: .destructive) { [weak self] _ in
                    guard let self = self else {return}
                    if let indexPath = self.indexPath {
                        self.analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
                        self.confirmingDeletionAlert(indexForDelete: indexPath)
                    }
                }
            ])
        }
    }
    
    private func confirmingDeletionAlert(indexForDelete indexPath: IndexPath) {
        let deleteCellString = NSLocalizedString("delete", comment: "text for delete button")
        let abortString = NSLocalizedString("cancel", comment: "text for cancel button")
        let titleForAlert = NSLocalizedString("delete.confirmation", comment: "Title for alert")
        let alert = UIAlertController(title: titleForAlert, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: deleteCellString, style: .destructive) { [weak self] _ in
            self?.deleteCell()
        }
        let cancelAction = UIAlertAction(title: abortString, style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.delegate?.confirmingDeletionAlert(alert: alert)
    }
    
        private func deleteCell() {
            guard let id = trackerId else {return}
            trackerStore.deleteTracker(id: id)
            print("Удаляем трекер")
        }
    private func editFlow(self: TrackerCollectionViewCell) {
        let vs = EditorViewController()
        vs.trackerType = .habit
        vs.categoryForTracker = self.categoryName
        vs.weekDaysArrayForTracker = self.weekDays
        vs.nameForTracker = self.descriptionLAble.text!
        vs.pickedEmojiAndColor(emoji: self.smileLabel.text!, color: self.color!)
        vs.id = self.trackerId
        vs.coudDays = countDays
        vs.configureSubviews()
        self.delegate?.showEditorView(controller: vs)
    }
}
