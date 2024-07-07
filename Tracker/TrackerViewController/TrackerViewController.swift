//
//  ViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 2.07.24.
//

import UIKit

final class TrackerViewController: UIViewController {

    private lazy var plusButton = UIButton()
    private lazy var datePicker = UIDatePicker()
    private lazy var trackerLable = UILabel()
    private lazy var searchField = UITextField()
    private lazy var placeholder = UIImageView()
    private lazy var placeholderLable = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addAllSubView()
    }
    
    private func addPlusButton() {
        let image = UIImage(named: "plus")
        plusButton.setImage(image, for: .normal)
        plusButton.tintColor = .ypBlack
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func addDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 77)
        ])
    }
    
    private func addTrackerLable() {
        trackerLable.text = "Трекеры"
        trackerLable.font = .systemFont(ofSize: 34, weight: .bold)
        trackerLable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLable)
        
        NSLayoutConstraint.activate([
            trackerLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerLable.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 1),
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
        searchField.placeholder = "Поиск"
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
        searchIcon.frame = CGRect(x: 8, y: 0, width: 16, height: 16)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
            paddingView.addSubview(searchIcon)
        searchField.leftView = paddingView
        searchField.leftViewMode = .unlessEditing
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: trackerLable.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36)
        ])
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
        placeholderLable.text = "Что будем отслеживать?"
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
    
    private func addAllSubView() {
        addPlusButton()
        addDatePicker()
        addTrackerLable()
        addSearchField()
        addPlaceholder()
        addPlaceholderLable()
    }
}

