//
//  onboardingViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 14.08.24.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    private let textForLable = ["Отслеживайте только то, что хотите", "Даже если это не литры воды и йога"]
    private let imageForControllers = [UIImage(named: "onboardingRed"), UIImage(named: "onboardingBlue")]
    
    private lazy var controllersForPVC: [UIViewController] = {
        let red = ViewControllerForOnboarding()
        red.configLableAndImage(text: textForLable[0], image: imageForControllers[0])
        let blue = ViewControllerForOnboarding()
        blue.configLableAndImage(text: textForLable[1], image: imageForControllers[1])
        return [red, blue]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = controllersForPVC.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = controllersForPVC.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        configureView()
    }
    
    func configureView() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = controllersForPVC.firstIndex(of: viewController) else {return nil}
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return controllersForPVC.last
        }
        return controllersForPVC[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = controllersForPVC.firstIndex(of: viewController) else {return nil}
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < controllersForPVC.count else {
            return controllersForPVC.first
        }
        return controllersForPVC[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = controllersForPVC.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

