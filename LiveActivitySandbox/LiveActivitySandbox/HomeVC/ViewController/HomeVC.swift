//
//  HomeVC.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import UIKit

class HomeVC: UIViewController {
    //Views
    private lazy var uiKitButton: UIButton = {
        let btn = UIButton(
            configuration: .tinted()
        )
        addAction(
            #selector(userDidPressUIKitButton),
            to: btn
        )
        
        return btn
    }()
    
    //Properties
    private let uiKitButtonTitle: String = "UIKit"
    
    
    //Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        setupViews()
        applyTheme()
    }
}

// MARK: - UserActions
private extension HomeVC {
    @objc func userDidPressUIKitButton() {
        let trackingVC = WorkoutTrackingVC()
        trackingVC.modalPresentationStyle = .fullScreen
        present(trackingVC, animated: true)
    }
}

// MARK: - Setup Related
private extension HomeVC {
    func layoutViews() {
        view.addSubview(uiKitButton)
        uiKitButton.centerXAndY(inView: view)
    }
    
    func setupViews() {
        uiKitButton.setTitle(uiKitButtonTitle, for: .normal)
    }
    
    func applyTheme() {
        view.backgroundColor = .white
    }
    
    //Helpers
    func addAction(_ actioin: Selector, to btn: UIButton) {
        btn.addTarget(self, action: actioin, for: .touchUpInside)
    }
}
