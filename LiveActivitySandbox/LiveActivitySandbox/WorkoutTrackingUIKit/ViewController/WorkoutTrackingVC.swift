//
//  WorkoutTrackingVC.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import UIKit
import Combine

class WorkoutTrackingVC: UIViewController {
    let viewModel = WorkoutTrackingViewModel()
    
    private lazy var infoText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        applyTheme()
        createSubscriptions()
    }
}

//MARK: - Reactions
private extension WorkoutTrackingVC {

}

//MARK: - Setup
private extension WorkoutTrackingVC {
    func layoutViews() {
        view.addSubview(infoText)
        infoText.fillSelf(
            inView: view,
            withPaddingAround: 25
        )
    }
    
    func applyTheme() {
        view.backgroundColor = .white
        infoText.font = .boldSystemFont(ofSize: 23)
        infoText.textColor = .black
    }
    
    func createSubscriptions() {
        viewModel.$infoString
            .receive(on: DispatchQueue.main.self)
            .sink { [weak self] infoString in
                self?.infoText.text = infoString
            }
            .store(in: &subscriptions)
    }
}
