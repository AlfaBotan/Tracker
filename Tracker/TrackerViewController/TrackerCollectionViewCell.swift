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
    static let Identifier = "TrackerCollectionViewCell"
    private let analyticsService = AnalyticsService()
    
    private lazy var topView = UIView()
    private lazy var smileLabel = UILabel()
    private lazy var descriptionLAble = UILabel()
    private lazy var countDaysLable = UILabel()
    private lazy var plusButton = UIButton()
    
    private var indexPath: IndexPath?
    private var trackerId: UUID? = nil
    private var isCompleted: Bool = false
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewsAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func configCell(id: UUID, name: String, color: UIColor, emoji: String, completedDays: Int, isEnabled: Bool, isCompleted: Bool, indexPath: IndexPath){
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
        self.isCompleted = isCompleted
    }
}

extension Int {
    func days() -> String {
        var dayString: String
        switch self {
        case 1:
            dayString = "день"
        case 2...4:
            dayString = "дня"
        default:
            dayString = "дней"
        }
        return "\(self) \(dayString)"
    }
}
