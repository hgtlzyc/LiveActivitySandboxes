//
//  WorkoutTrackingVC.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import UIKit

class WorkoutTrackingVC: UIViewController {
    let viewModel = WorkoutTrackingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        applyTheme()
    }
}

//MARK: - LocationManager Reactions
private extension WorkoutTrackingVC {

}

//MARK: - Setup
private extension WorkoutTrackingVC {
    func layoutViews() {
        
    }
    
    func applyTheme() {
        view.backgroundColor = .red
    }
}
