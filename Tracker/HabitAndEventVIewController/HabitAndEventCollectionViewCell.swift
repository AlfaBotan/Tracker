//
//  HabitAndEventCollectionViewCell.swift
//  Tracker
//
//  Created by Илья Волощик on 25.07.24.
//

import UIKit

final class HabitAndEventCollectionViewCell: UICollectionViewCell {
    
    static let Identifier = "HabitAndEventCollectionViewCell"
    private lazy var backView = UIView()
    private lazy var smileLabel = UILabel()
    private lazy var colorView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        addSubviewsAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviewsAndConstraints() {
        backView.backgroundColor = .ypWhite
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 8

        smileLabel.backgroundColor = .ypWhite
        smileLabel.layer.masksToBounds = true
        smileLabel.layer.cornerRadius = 16
        smileLabel.textAlignment = .center
        smileLabel.font = .systemFont(ofSize: 32, weight: .bold)
        
        colorView.backgroundColor = .ypWhite
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = 8
        
        backView.translatesAutoresizingMaskIntoConstraints = false
        smileLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backView)
        backView.addSubview(colorView)
        backView.addSubview(smileLabel)
        
        NSLayoutConstraint.activate([
            backView.heightAnchor.constraint(equalToConstant: 46),
            backView.widthAnchor.constraint(equalToConstant: 46),
            backView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            smileLabel.heightAnchor.constraint(equalToConstant: 38),
            smileLabel.widthAnchor.constraint(equalToConstant: 32),
            smileLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            smileLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configEmojiCell(emoji: String) {
        smileLabel.text = emoji
        colorView.isHidden = true
        contentView.layer.cornerRadius = 16
    }
    
    func configColorCell(color: UIColor) {
        smileLabel.isHidden = true
        colorView.backgroundColor = color
        contentView.layer.cornerRadius = 8
    }
    
    func deselectEmoji() {
        contentView.backgroundColor = .ypWhite
        backView.backgroundColor = .ypWhite
        colorView.backgroundColor = .ypWhite
        smileLabel.backgroundColor = .ypWhite
    }
    
    func deselectColor() {
        contentView.backgroundColor = .ypWhite
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.borderWidth = 0
    }
    
    func selectEmoji() {
        contentView.backgroundColor = .ypLightGray
        backView.backgroundColor = .ypLightGray
        colorView.backgroundColor = .ypLightGray
        smileLabel.backgroundColor = .ypLightGray
    }
    
    func selectColor(color: UIColor) {
        contentView.layer.borderColor = color.cgColor
        contentView.layer.borderWidth = 3
    }
    
    func reset() {
        smileLabel.text = ""
        colorView.isHidden = false
        smileLabel.isHidden = false
        colorView.backgroundColor = .white
        backView.backgroundColor = .white
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.borderWidth = 0
    }
}
