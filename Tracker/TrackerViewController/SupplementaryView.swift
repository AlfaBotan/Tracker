//
//  SuplementaryView.swift
//  Tracker
//
//  Created by Илья Волощик on 15.07.24.
//

import UIKit

final class SupplementaryView: UICollectionReusableView {
    lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
