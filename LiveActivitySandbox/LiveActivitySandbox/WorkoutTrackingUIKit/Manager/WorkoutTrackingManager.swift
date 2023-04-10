//
//  WorkoutTrackingManager.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/31/23.
//

import Accelerate
import CoreLocation

actor WorkoutTrackingManager {
    //SOC
    private var trackedLocations: [CLLocation]?
}

//MARK: - Parent Accessable
extension WorkoutTrackingManager {
    //Create
    func addLocation(_ location: CLLocation) {
        switch trackedLocations {
        case nil:
            trackedLocations = [location]
        case _?:
            trackedLocations?.append(location)
        }
    }
    
    //Read
    var nonNegativeSpeedLocations: [CLLocation]? {
        switch trackedLocations {
        case nil:
            assertionFailure(
                "trying to read tracked locations before add locations"
            )
            return nil
        case let locations?:
            return getNonNegativeSpeedLocations(
                basedOn: locations
            )
        }
    }
    
    var totalNumberOfDataPointsTracked: Int? {
        trackedLocations?.count
    }
    
    var totalNumberOfDataPointsSent: Int? {
        nonNegativeSpeedLocations?.count
    }
    
    //Helper
    private func getNonNegativeSpeedLocations(
        basedOn locations: [CLLocation]
    ) -> [CLLocation] {
        locations.filter { location in
            location.speed >= 0
        }
    }
}
