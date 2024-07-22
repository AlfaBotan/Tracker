//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 21.07.24.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private lazy var titleLable = UILabel()
    private lazy var categoryTableView = UITableView(frame: .zero)
    private lazy var placeholder = UIImageView()
    private lazy var placeholderLable = UILabel()
    private lazy var addCategoryButton = UIButton()
    
    var categoryForTableView: [String] = [
        "Спорт", "Учёба", "Домашние дела", "Работа"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        configureSubviews()
        showOrHideTableView()
    }
    
    private func configureSubviews() {
        titleLable.text = "Категория"
        titleLable.font = .systemFont(ofSize: 16, weight: .medium)
        titleLable.textAlignment = .center
        titleLable.textColor = .ypBlack
        
        
        categoryTableView.register(CategoryTableViewСеll.self, forCellReuseIdentifier: CategoryTableViewСеll.identifer)
        categoryTableView.separatorStyle = .singleLine
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        categoryTableView.layer.masksToBounds = true
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        placeholder.image = UIImage(named: "placeholder")
        
        placeholderLable.text = """
                                Привычки и события можно
                                объединить по смыслу
                                """
        placeholderLable.numberOfLines = 2
        placeholderLable.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLable.textAlignment = .center
        
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.backgroundColor = .ypBlack
        addCategoryButton.tintColor = .ypWhite
        addCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.layer.masksToBounds = true
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonClicked), for: .touchUpInside)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholderLable.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLable)
        view.addSubview(placeholder)
        view.addSubview(placeholderLable)
        view.addSubview(categoryTableView)
        view.addSubview(addCategoryButton)

        
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLable.heightAnchor.constraint(equalToConstant: 22),

            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 66),
            categoryTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -92),
            
            placeholder.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholder.widthAnchor.constraint(equalToConstant: 70),
            placeholder.heightAnchor.constraint(equalToConstant: 70),
            
            placeholderLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderLable.topAnchor.constraint(equalTo: placeholder.bottomAnchor, constant: 8),
            placeholderLable.heightAnchor.constraint(equalToConstant: 36),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func showOrHideTableView() {
        if categoryForTableView.isEmpty {
            categoryTableView.isHidden = true
        } else {
            categoryTableView.isHidden = false
        }
    }
    
    @objc private func addCategoryButtonClicked() {
        let viewController = CreateCategoryViewController()
        present(viewController, animated: true)
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewСеll else {
            assertionFailure("Не удалось выполнить приведение к CategoryTableViewСеll")
            return
            }
        cell.showOrHideDoneImg()
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewСеll.identifer, for: indexPath) as? CategoryTableViewСеll else {
            assertionFailure("Не удалось выполнить приведение к CategoryTableViewСеll")
            return UITableViewCell()
            }
        
        let category = categoryForTableView[indexPath.row]
        cell.configureCell(textLable: category)
        cell.backgroundColor = .ypBackground
        return cell
        }
    
    }
