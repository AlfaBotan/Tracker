//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 22.08.24.
//

import UIKit

protocol FilterViewControllerProtocol: AnyObject {
    func saveChoise(filter: FiltersCases)
}

final class FiltersViewController: UIViewController {
    weak var delegate: FilterViewControllerProtocol?

    private let rowsForTableView: [FiltersCases] = [.allTrackers, .trackersOnToday, .completedTrackers, .unCompletedTrackers]
    private lazy var titleLable = UILabel()
    private lazy var categoryTableView = UITableView(frame: .zero)
    private var pickedCase: FiltersCases?
    
    init(filter: FiltersCases?) {
        if let pitedCase = filter {
            self.pickedCase = pitedCase
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        configureSubviews()
    }
    
    private func configureSubviews() {
        titleLable.text = "Фильтры"
        titleLable.font = .systemFont(ofSize: 16, weight: .medium)
        titleLable.textAlignment = .center
        titleLable.textColor = .ypBlack
        
        categoryTableView.register(FiltersTableViewCell.self, forCellReuseIdentifier: FiltersTableViewCell.identifer)
        categoryTableView.separatorStyle = .singleLine
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        categoryTableView.layer.masksToBounds = true
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLable)
        view.addSubview(categoryTableView)
        
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLable.heightAnchor.constraint(equalToConstant: 22),
            
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 66),
            categoryTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -92)
        ])
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? FiltersTableViewCell else {
            assertionFailure("Не удалось выполнить приведение к CategoryTableViewСеll")
            return
        }
        
        cell.showOrHideDoneImg()
        let pick = rowsForTableView[indexPath.row]
        pickedCase = pick
        delegate?.saveChoise(filter: pick)
        dismiss(animated: true)
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FiltersTableViewCell.identifer, for: indexPath) as? FiltersTableViewCell else {
            assertionFailure("Не удалось выполнить приведение к CategoryTableViewСеll")
            return UITableViewCell()
        }
        if let filterCase = pickedCase {
            let index = rowsForTableView.firstIndex(of: filterCase)
            if index == indexPath.row {
                cell.showOrHideDoneImg()
            }
        }
        let filter = rowsForTableView[indexPath.row]
        cell.configureCell(textLable: filter.text)
        cell.backgroundColor = .ypBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if totalRows == 1 {
            cell.layer.cornerRadius = 16
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            return
        }
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = tableView.separatorInset
        case totalRows - 1:
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        default:
            cell.layer.cornerRadius = 0
            cell.separatorInset = tableView.separatorInset
        }
    }
}



