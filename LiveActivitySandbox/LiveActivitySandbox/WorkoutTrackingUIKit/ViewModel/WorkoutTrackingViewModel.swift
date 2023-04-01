//
//  WorkoutTrackingViewModel.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/30/23.
//

import UIKit
import MapKit
import CoreLocation

class WorkoutTrackingViewModel: NSObject {
    
    override init() {
        super.init()
    }
}

// MARK: - MapView Related
extension WorkoutTrackingViewModel {
    func generateMapView() {
        let mapView = MKMapView()
    }
}

extension WorkoutTrackingViewModel: MKMapViewDelegate {
    
}

// MARK: - Location Manager
private extension WorkoutTrackingViewModel {
    
}
