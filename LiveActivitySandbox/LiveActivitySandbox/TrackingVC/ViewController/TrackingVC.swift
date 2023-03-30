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
    
    private let locationUpdateDebounceInSecs: Double = 0.5
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        createSubscriptions()
        applyTheme()
    }
}

//MARK: - Reactions
private extension TrackingVC {
    func reactToAuthState(_ state: CLAuthorizationStatus?) {
        guard let state else { return }
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
    
    func reactToLocationUpdate(_ location: CLLocation?) {
        guard let location else { return }
        print(location)
    }
}

//MARK: - Setup
private extension TrackingVC {
    func layoutViews() {
        
    }
    
    func applyTheme() {
        view.backgroundColor = .red
    }
    
    func createSubscriptions() {
        LocationManager.shared
            .$authStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.reactToAuthState(state)
            }
            .store(in: &subscriptions)
        
        LocationManager.shared
            .$location
            .debounce(
                for: .seconds(locationUpdateDebounceInSecs),
                scheduler: DispatchQueue.main
            )
            .sink { [weak self] location in
                self?.reactToLocationUpdate(location)
            }
            .store(in: &subscriptions)
    }
    
}
