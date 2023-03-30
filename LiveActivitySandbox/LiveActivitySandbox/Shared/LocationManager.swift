//
//  LocationManager.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/29/23.
//

import CoreLocation
import Combine

class LocationManager: NSObject {
    static let shared = LocationManager()
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    //Data
    private let locationManager = CLLocationManager()
    
    //Publishers
    @Published private(set) var authStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var location: CLLocation? = nil
}

//MARK: - Public Accessable
extension LocationManager {
    func startUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

//MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach {
            location = $0
        }
    }
}

//MARK: - Setup
private extension LocationManager {
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
    }
}
