//
//  AppLaunch.swift
//  CountriesListApp
//
//  Created by Duale A on 4/29/25.
//


// i did this just because from practise and user experience a good launch is a good user experience .

import UIKit


final class LaunchViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Countries App"
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        animateTitle()
    }
    
    // The title when the app launches. could have named anything but since it is a coutries app made it countrieApp

    private func animateTitle() {
        UIView.animate(withDuration: 1.2,
                       delay: 0.2,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                self.titleLabel.transform = .identity
            }, completion: { _ in
                self.transitionToMain()
            })
        })
    }
  // Here i made after this launch i transition to the main 
    private func transitionToMain() {
        let mainVC = CountriesViewController()
        let navVC = UINavigationController(rootViewController: mainVC)
        navVC.modalTransitionStyle = .crossDissolve
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}

