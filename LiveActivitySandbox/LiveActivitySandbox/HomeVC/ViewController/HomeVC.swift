//
//  HomeVC.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import UIKit

class HomeVC: UIViewController {

    private lazy var uiKitButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(
            self,
            action: #selector(userDidPressUIKitButton),
            for: .touchUpInside
        )
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        applyTheme()
    }
}

// MARK: - UserActions
private extension HomeVC {
    @objc func userDidPressUIKitButton() {
        
    }
}

// MARK: - Setup Helpers
private extension HomeVC {
    func layoutViews() {
        
    }
    
    func applyTheme() {
        
    }
}

