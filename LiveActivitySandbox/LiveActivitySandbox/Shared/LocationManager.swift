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
    @Published private(set) var authStatus: CLAuthorizationStatus? = nil
    @Published private(set) var location: CLLocation? = nil
}

//MARK: - Public Accessable
extension LocationManager {
    func requestAlwaysAuth() {
        locationManager.requestAlwaysAuthorization()
    }
    
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
        //https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager
        //Apple doc states at least one location pass back
        if locations.isEmpty {
            Log.warning("unexpected empty locations")
        }
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
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.delegate = self
    }
}
