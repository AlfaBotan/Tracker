//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 21.07.24.
//

import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func getCategoryFromModel()
}

final class CreateCategoryViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    weak var categoryViewModel: CategoryViewModel!
    weak var delegate: CreateCategoryViewControllerDelegate?
    
    private lazy var titleLable = UILabel()
    private lazy var categoryTextField = UITextField()
    private lazy var doneButton = UIButton()
    private var textFromTextField: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureSubviews()
        setupToHideKeyboardOnTapOnView()
    }
    
    private func configureSubviews() {
        titleLable.text = "Новая категория"
        titleLable.font = .systemFont(ofSize: 16, weight: .medium)
        titleLable.textAlignment = .center
        titleLable.textColor = .ypBlack
        
        categoryTextField.backgroundColor = .ypBackground
        categoryTextField.layer.masksToBounds = true
        categoryTextField.layer.cornerRadius = 15
        categoryTextField.font = .systemFont(ofSize: 16, weight: .regular)
        categoryTextField.placeholder = "Введите название категории"
        categoryTextField.textAlignment = .left
        categoryTextField.textColor = .ypBlack
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        categoryTextField.leftView = leftView
        categoryTextField.leftViewMode = .always
        categoryTextField.clearButtonMode = .whileEditing
        categoryTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        categoryTextField.delegate = self
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .ypGray
        doneButton.tintColor = .ypWhite
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        doneButton.isEnabled = false
        
        view.addSubview(titleLable)
        view.addSubview(categoryTextField)
        view.addSubview(doneButton)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLable.heightAnchor.constraint(equalToConstant: 22),
            
            categoryTextField.heightAnchor.constraint(equalToConstant: 75),
            categoryTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTextField.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 24),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneButtonClicked() {
        trackerCategoryStore.saveNewCategory(title: textFromTextField!)
        delegate?.getCategoryFromModel()
        dismiss(animated: true)
    }
    
    @objc private func textFieldEditingChanged() {
        if let text = categoryTextField.text, !text.isEmpty {
            textFromTextField = text
            activateDoneButton()
        } else {
            deactivateDoneButton()
        }
    }
    
    private func activateDoneButton() {
        doneButton.backgroundColor = .ypBlack
        doneButton.isEnabled = true
    }
    
    private func deactivateDoneButton() {
        doneButton.backgroundColor = .ypGray
        doneButton.isEnabled = false
    }
}

extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
