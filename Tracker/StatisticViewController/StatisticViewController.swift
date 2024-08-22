//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 3.07.24.
//

import UIKit

final class StatisticViewController: UIViewController, TrackerViewControllerDelegateForStatistic {
    
    private let trackerRecordStore = TrackerRecordStore()
    
    private var countDays: Int = 0
    
    private lazy var titleLable = UILabel()
    private lazy var placeholder = UIImageView()
    private lazy var placeholderLable = UILabel()
    private lazy var holderForStatistic = UIView()
    private lazy var countLable = UILabel()
    private lazy var descriptionLable = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        whatsShow(days: trackerRecordStore.getAllTrackerRecords().count)
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientBorder()
    }
    
    private func applyGradientBorder() {
        // Удаляем предыдущий градиентный слой, если он уже добавлен
        if let sublayers = holderForStatistic.layer.sublayers, sublayers.count > 0 {
            for layer in sublayers where layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = holderForStatistic.bounds
        gradientLayer.cornerRadius = holderForStatistic.layer.cornerRadius
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: holderForStatistic.bounds, cornerRadius: holderForStatistic.layer.cornerRadius).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        holderForStatistic.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configureView() {
        titleLable.text = "Статистика"
        titleLable.font = .systemFont(ofSize: 34, weight: .bold)
        
        holderForStatistic.layer.masksToBounds = true
        holderForStatistic.layer.cornerRadius = 16
        holderForStatistic.layer.borderWidth = 1
        holderForStatistic.layer.borderColor = UIColor.clear.cgColor
        
        countLable.text = "\(countDays)"
        countLable.font = .systemFont(ofSize: 34, weight: .bold)
        
        descriptionLable.text = "Трекеров завершено"
        descriptionLable.font = .systemFont(ofSize: 12, weight: .medium)
        
        placeholder.image = UIImage(named: "statisticNil")
        placeholderLable.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLable.text = "Анализировать пока нечего"
        placeholderLable.textAlignment = .center
        
        countLable.translatesAutoresizingMaskIntoConstraints = false
        descriptionLable.translatesAutoresizingMaskIntoConstraints = false
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholderLable.translatesAutoresizingMaskIntoConstraints = false
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        holderForStatistic.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(holderForStatistic)
        view.addSubview(titleLable)
        view.addSubview(placeholder)
        view.addSubview(placeholderLable)
        holderForStatistic.addSubview(countLable)
        holderForStatistic.addSubview(descriptionLable)
        
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLable.topAnchor.constraint(equalTo: placeholder.bottomAnchor,constant: 8),
            placeholderLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            holderForStatistic.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            holderForStatistic.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            holderForStatistic.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 75),
            holderForStatistic.heightAnchor.constraint(equalToConstant: 90),
            
            countLable.leadingAnchor.constraint(equalTo: holderForStatistic.leadingAnchor, constant: 12),
            countLable.topAnchor.constraint(equalTo: holderForStatistic.topAnchor, constant: 12),
            countLable.trailingAnchor.constraint(equalTo: holderForStatistic.trailingAnchor, constant: -12),
            countLable.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionLable.leadingAnchor.constraint(equalTo: countLable.leadingAnchor),
            descriptionLable.topAnchor.constraint(equalTo: countLable.bottomAnchor),
            descriptionLable.trailingAnchor.constraint(equalTo: countLable.trailingAnchor),
            descriptionLable.bottomAnchor.constraint(equalTo: holderForStatistic.bottomAnchor, constant: -12)
        ])
    }
    
    func whatsShow(days: Int) {
        countDays = days
        countLable.text = "\(countDays)"
        if countDays == 0 {
            holderForStatistic.isHidden = true
            placeholder.isHidden = false
            placeholderLable.isHidden = false
        } else {
            holderForStatistic.isHidden = false
            placeholder.isHidden = true
            placeholderLable.isHidden = true
        }
    }
}

