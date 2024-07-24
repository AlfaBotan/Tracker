//
//  WeekdaysViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 22.07.24.
//

import UIKit

protocol WeekdaysViewControllerDelegate: AnyObject {
    func weekdaysIsPicket(weekDaysArray: [Weekdays])
    func updateCreateButtonState()
}

final class WeekdaysViewController: UIViewController {
    
    private lazy var titleLable = UILabel()
    private lazy var weekdaysTableView = UITableView(frame: .zero)
    private lazy var doneButton = UIButton()
    private var switchStates: [Bool] = [false, false, false, false, false, false, false]
    var weekDaysArrayFromVC: [Weekdays] = []
    weak var delegate: WeekdaysViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        view.backgroundColor = .ypWhite
        weekdaysTableView.dataSource = self
        weekdaysTableView.delegate = self
        configureSubviews()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.weekdaysIsPicket(weekDaysArray: weekDaysArrayFromVC)
    }
    
    private func configureSubviews() {
        titleLable.text = "Расписание"
        titleLable.font = .systemFont(ofSize: 16, weight: .medium)
        titleLable.textAlignment = .center
        titleLable.textColor = .ypBlack
        
        weekdaysTableView.register(WeekdaysTableViewCell.self, forCellReuseIdentifier: WeekdaysTableViewCell.identifer)
        weekdaysTableView.separatorStyle = .singleLine
        weekdaysTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        weekdaysTableView.layer.masksToBounds = true
        weekdaysTableView.layer.cornerRadius = 16
        weekdaysTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .ypGray
        doneButton.tintColor = .ypWhite
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        doneButton.isEnabled = false
        
        view.addSubview(titleLable)
        view.addSubview(weekdaysTableView)
        view.addSubview(doneButton)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        weekdaysTableView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLable.heightAnchor.constraint(equalToConstant: 22),
            
            weekdaysTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 66),
            weekdaysTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            weekdaysTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            weekdaysTableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneButtonClicked() {
        delegate?.weekdaysIsPicket(weekDaysArray: weekDaysArrayFromVC)
        delegate?.updateCreateButtonState()
        dismiss(animated: true)
    }
    
    private func activateDoneButton() {
        doneButton.backgroundColor = .ypBlack
        doneButton.isEnabled = true
    }
    
    private func deactivateDoneButton() {
        doneButton.backgroundColor = .ypGray
        doneButton.isEnabled = false
    }
    
    func updatedoneButtonnState() {
        if switchStates.contains(true) {
            activateDoneButton()
        } else {
            deactivateDoneButton()
        }
    }
}

extension WeekdaysViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension WeekdaysViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekdays.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekdaysTableViewCell.identifer, for: indexPath) as? WeekdaysTableViewCell else {
            assertionFailure("Не удалось выполнить приведение к WeekdaysTableViewCell")
            return UITableViewCell()
        }
        
        let weekday = Weekdays.allCases[indexPath.row]
        cell.configureCell(textLable: weekday.rawValue)
        for i in weekDaysArrayFromVC {
            if i.rawValue == weekday.rawValue {
                self.switchStates[indexPath.row] = true
                cell.configureSwitchButtonStat(isOn: true)
            }
        }
        cell.backgroundColor = .ypBackground
        cell.delegate = self
        updatedoneButtonnState()
        return cell
    }
}

extension WeekdaysViewController: WeekdaysTableViewCellDelegate {
    func switchValueChanged(in cell: WeekdaysTableViewCell) {
        if let indexPath = weekdaysTableView.indexPath(for: cell) {
            switchStates[indexPath.row] = cell.checkSwitchButtonStat()
            let weekDay = Weekdays.allCases[indexPath.row]
            if let weekdayIndex = weekDaysArrayFromVC.firstIndex(where: {$0 == weekDay}) {
                weekDaysArrayFromVC.remove(at: weekdayIndex)
                updatedoneButtonnState()
                return
            }
            weekDaysArrayFromVC.append(weekDay)
            updatedoneButtonnState()
        }
    }
}



