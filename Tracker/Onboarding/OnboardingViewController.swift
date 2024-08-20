//
//  onboardingViewController.swift
//  Tracker
//
//  Created by Илья Волощик on 14.08.24.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    var showMainView: (() -> Void)?
    private lazy var controllersForPVC: [UIViewController] = {
        let first = ViewControllerForOnboarding()
        first.configLableAndImage(onboardingPage: .firstPage)
        first.onOnboardingFinished = { [weak self] in
            self?.showMain()
        }
        let second = ViewControllerForOnboarding()
        second.configLableAndImage(onboardingPage: .secondPage)
        second.onOnboardingFinished = { [weak self] in
            self?.showMain()
        }
        return [first, second]
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
    
    private func showMain() {
        showMainView?()
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

