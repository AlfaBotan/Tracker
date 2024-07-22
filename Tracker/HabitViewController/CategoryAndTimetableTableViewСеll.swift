//
//  CategoryAndTimetableTableViewСеll.swift
//  Tracker
//
//  Created by Илья Волощик on 20.07.24.
//

import UIKit

final class CategoryAndTimetableTableViewСеll: UITableViewCell {
    
    static let identifer = "CategoryAndTimetableTableViewСеll"
    
    private lazy var chevronImg: UIImageView = {
            return UIImageView(image: UIImage(named: "chevron"))
        }()
    
    private lazy var nameLable = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     func configureSubviews() {
            
            nameLable.translatesAutoresizingMaskIntoConstraints = false
            chevronImg.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(chevronImg)
            contentView.addSubview(nameLable)
        
            let heightCell = contentView.heightAnchor.constraint(equalToConstant: 75)
            heightCell.priority = .defaultHigh
        
            NSLayoutConstraint.activate([
                heightCell,
                chevronImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
                chevronImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                chevronImg.heightAnchor.constraint(equalToConstant: 24),
                chevronImg.widthAnchor.constraint(equalToConstant: 24),
                
                nameLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                nameLable.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
                nameLable.trailingAnchor.constraint(equalTo: chevronImg.leadingAnchor)
            ])
        }
    
    func configureCell(textLable: String) {
        nameLable.text = textLable
        }
}
