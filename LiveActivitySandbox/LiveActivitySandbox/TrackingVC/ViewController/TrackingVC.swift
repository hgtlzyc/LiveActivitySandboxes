//
//  TrackingVC.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import UIKit
import Combine
import MapKit

class TrackingVC: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        setupViews()
        applyTheme()
    }
}

//MARK: - Reacts
private extension TrackingVC {
    func reactToAuthState(_ state: CLAuthorizationStatus) {
        switch state {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
        case .authorized:
            print("authorized")
        @unknown default:
            break
        }
    }
}

//MARK: - Setup
private extension TrackingVC {
    func layoutViews() {
        
    }
    
    func setupViews() {
        LocationManager.shared.$authStatus.sink { [weak self] state in
            self?.reactToAuthState(state)
        }.store(in: &subscriptions)
    }
    
    func applyTheme() {
        view.backgroundColor = .red
    }
}
