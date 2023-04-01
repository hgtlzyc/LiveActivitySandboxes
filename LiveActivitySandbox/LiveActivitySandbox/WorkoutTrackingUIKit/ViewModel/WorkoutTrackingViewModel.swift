//
//  WorkoutTrackingViewModel.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/30/23.
//

import UIKit
import Combine
import MapKit
import CoreLocation

class WorkoutTrackingViewModel: NSObject {
    // MARK: - Properties
    //Location Manager
    private let locationUpdateDebounceInSecs: Double = 0.5
    private lazy var locationManager: LocationManager = {
        LocationManager.shared
    }()
    private var subscriptions: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        createSubscriptions()
    }
}

// MARK: - LoicationManager Reactions
private extension WorkoutTrackingViewModel {
    func reactToAuthState(_ state: CLAuthorizationStatus?) {
        guard let state else {
            Log.info("waiting for location auth status update")
            return
        }
        
        switch state {
        case .notDetermined:
            locationManager.requestAlwaysAuth()
        case .authorizedAlways:
            locationManager.startUpdates()
        case .restricted, .denied, .authorizedWhenInUse:
            assertionFailure("needs always auth for demo")
        case .authorized:
            assertionFailure("unexpected state for iOS")
        @unknown default:
            assertionFailure("unexpected state")
        }
    }
    
    func reactToLocationUpdate(_ location: CLLocation?) {
        guard let location else {
            Log.info("waiting for location value update")
            return
        }
        Log.debug("\(location)")
    }
}

// MARK: - LocationManager Setup
private extension WorkoutTrackingViewModel {
    func createSubscriptions() {
        locationManager
            .$authStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.reactToAuthState(state)
            }
            .store(in: &subscriptions)
        
        locationManager
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
