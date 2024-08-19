//
//  ViewControllerForOnboarding.swift
//  Tracker
//
//  Created by Илья Волощик on 14.08.24.
//

import UIKit

final class ViewControllerForOnboarding: UIViewController {
    private lazy var button = UIButton()
    private lazy var lable = UILabel()
    private lazy var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
    }
    
    private func configureSubviews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Вот это технологии!", for: .normal)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(targetForButton), for: .touchUpInside)
        
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = .systemFont(ofSize: 32, weight: .bold)
        lable.textAlignment = .center
        lable.textColor = .ypBlack
        lable.numberOfLines = 2
        
        view.addSubview(imageView)
        view.addSubview(lable)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            lable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 15),
            
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc
    func targetForButton() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        if let window = UIApplication.shared.windows.first {
            let newViewController = TabBarViewController()
            window.rootViewController = newViewController
            window.makeKeyAndVisible()
        }
    }
    
    func configLableAndImage(text: String, image: UIImage?) {
        lable.text = text
        imageView.image = image
    }
}
