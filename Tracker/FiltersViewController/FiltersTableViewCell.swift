//
//  FiltersTableViewCell.swift
//  Tracker
//
//  Created by Илья Волощик on 22.08.24.
//

import UIKit

final class FiltersTableViewCell: UITableViewCell {
    
    static let identifer = "FiltersTableViewCell"
    
    private lazy var doneImg: UIImageView = {
        return UIImageView(image: UIImage(named: "doneBlue"))
    }()
    
    private lazy var categoryLable = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.cornerRadius = 0
        layer.masksToBounds = false
    }
    
    private func configureSubviews() {
        
        doneImg.isHidden = true
        
        categoryLable.translatesAutoresizingMaskIntoConstraints = false
        doneImg.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(doneImg)
        contentView.addSubview(categoryLable)
        
        let heightCell = contentView.heightAnchor.constraint(equalToConstant: 75)
        heightCell.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            heightCell,
            doneImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            doneImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            doneImg.heightAnchor.constraint(equalToConstant: 24),
            doneImg.widthAnchor.constraint(equalToConstant: 24),
            
            categoryLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryLable.trailingAnchor.constraint(equalTo: doneImg.leadingAnchor)
        ])
    }
    
    func configureCell(textLable: String) {
        prepareForReuse()
        categoryLable.text = textLable
    }
    
    func showOrHideDoneImg() {
        doneImg.isHidden = !doneImg.isHidden
    }
    
    func getChoiсe() -> String {
        guard let text = categoryLable.text else {return "Без категории"}
        return text
    }
}
