//
//  EventViewControllerCell.swift
//  Tracker
//
//  Created by Илья Волощик on 22.07.24.
//

import UIKit

final class HabitAndEventTableViewСеll: UITableViewCell {
    
    static let identifer = "HabitAndEventTableViewСеll"
    var descriptionLableIsEmpty = false {
            didSet {
                updateConstraintsForDescriptionLabel()
            }
        }
    
    private lazy var chevronImg: UIImageView = {
        return UIImageView(image: UIImage(named: "chevron"))
    }()
    private lazy var nameLable = UILabel()
    private lazy var descriptionLable = UILabel()
    private var descriptionLabelTopConstraint: NSLayoutConstraint!
    private var nameLabelCenterYConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        nameLable.font = .systemFont(ofSize: 17, weight: .regular)
        nameLable.textColor = .black
        
        descriptionLable.font = .systemFont(ofSize: 17, weight: .regular)
        descriptionLable.textColor = .gray
        
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        descriptionLable.translatesAutoresizingMaskIntoConstraints = false
        chevronImg.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLable)
        contentView.addSubview(descriptionLable)
        contentView.addSubview(chevronImg)
        
        let heightCell = contentView.heightAnchor.constraint(equalToConstant: 75)
        heightCell.priority = .defaultHigh
        
        nameLabelCenterYConstraint = nameLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        descriptionLabelTopConstraint = descriptionLable.topAnchor.constraint(equalTo: nameLable.bottomAnchor, constant: 4)
        
        NSLayoutConstraint.activate([
            heightCell,
            chevronImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            chevronImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImg.heightAnchor.constraint(equalToConstant: 24),
            chevronImg.widthAnchor.constraint(equalToConstant: 24),
            
            nameLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLable.trailingAnchor.constraint(equalTo: chevronImg.leadingAnchor),
            nameLable.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            descriptionLable.leadingAnchor.constraint(equalTo: nameLable.leadingAnchor),
            descriptionLable.trailingAnchor.constraint(equalTo: nameLable.trailingAnchor),
            descriptionLable.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        updateConstraintsForDescriptionLabel()
    }
    
    private func updateConstraintsForDescriptionLabel() {
            if descriptionLableIsEmpty {
                descriptionLable.isHidden = true
                descriptionLabelTopConstraint.isActive = false
                nameLabelCenterYConstraint.isActive = true
            } else {
                descriptionLable.isHidden = false
                nameLabelCenterYConstraint.isActive = false
                descriptionLabelTopConstraint.isActive = true
            }
        }
    
    func configureNameLable(textNameLable: String) {
        nameLable.text = textNameLable
    }
    
    func configureDescriptionLable(textDescriptionLable: String) {
        var text = textDescriptionLable
        if text.last == "," {
            text.removeLast()
        }
        descriptionLable.text = text
    }
}
