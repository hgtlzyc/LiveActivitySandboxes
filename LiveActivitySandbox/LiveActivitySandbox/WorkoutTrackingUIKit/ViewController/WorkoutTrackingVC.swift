//
//  WorkoutTrackingVC.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import UIKit
import Combine
import MapKit

class WorkoutTrackingVC: UIViewController {
    // MARK: - Views
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        
        return mapView
    }()
    
    //Data
    private let locationUpdateDebounceInSecs: Double = 0.5
    
    private lazy var locationManager: LocationManager = {
        LocationManager.shared
    }()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        createSubscriptions()
        applyTheme()
    }
}

// MARK: - MapView Delegate
extension WorkoutTrackingVC: MKMapViewDelegate {
    
}

//MARK: - LocationManager Reactions
private extension WorkoutTrackingVC {
    func reactToAuthState(_ state: CLAuthorizationStatus?) {
        guard let state else {
            Log.info("waiting for location auth status update")
            return
        }
        let statusMessage: String
        switch state {
        case .notDetermined:
            statusMessage = "notDetermined"
        case .restricted:
            statusMessage = "restricted"
        case .denied:
            statusMessage = "denied"
        case .authorizedAlways:
            statusMessage = "authorizedAlways"
        case .authorizedWhenInUse:
            statusMessage = "authorizedWhenInUse"
        case .authorized:
            statusMessage = "authorized"
        @unknown default:
            statusMessage = "unexpected"
            break
        }
        Log.debug(statusMessage)
    }
    
    func reactToLocationUpdate(_ location: CLLocation?) {
        guard let location else {
            Log.info("waiting for location value update")
            return
        }
        print(location)
    }
}

//MARK: - Setup
private extension WorkoutTrackingVC {
    func layoutViews() {
        
    }
    
    func applyTheme() {
        view.backgroundColor = .red
    }
    
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
