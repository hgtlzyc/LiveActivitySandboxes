//
//  WorkoutTrackingManager.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/31/23.
//

import Accelerate
import Combine
import CoreLocation

actor WorkoutTrackingManager {
    //SOC
    var dateStarted: Date?
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
    var totalDistance: Double? {
        totalDistanceInMetersBasedOn(
            trackedLocations
        )?.rounded()
    }
    
    var speeds: [Double] {
        getSpeeds(basedOn: trackedLocations)
    }
    
    var minSpeed: Double {
        vDSP.minimum(speeds)
    }
    
    var avgSpeed: Double {
        guard speeds.count > 1 else {
            return 0
        }
        return vDSP.mean(speeds)
    }
    
    var maxSpeed: Double {
        guard speeds.count > 1 else {
            return 0
        }
        return vDSP.maximum(speeds)
    }
}

//MARK: - Helpers
private extension WorkoutTrackingManager {
    //Distance Calculation
    func totalDistanceInMetersBasedOn(
        _ locations: [CLLocation]?
    ) -> Double? {
        guard let locations else {
            return nil
        }
        guard locations.count > 1 else {
            return 0.0
        }
        
        let coordinates = locations.map(\.coordinate)
        var runningRef: CLLocationCoordinate2D?
        let distances: [Double?] = coordinates.map { next in
            defer {
                runningRef = next
            }
            switch runningRef {
            case nil:
                return nil
            case let runningRef?:
                return distanceInMetersBetween(coord1: runningRef, coord2: next)
            }
        }
        
        return distances.compactMap{$0}.reduce(0, +)
    }
    
    func distanceInMetersBetween(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> Double {
        let locs = [coord1, coord2].map{ CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        return locs[0].distance(from: locs[1])
    }
    
    //Speed Calculation
    func getSpeeds(
        basedOn locations: [CLLocation]?
    ) -> [Double] {
        guard let locations else {
            return []
        }
        guard locations.count > 1 else {
            return [0.0]
        }
        return locations.map {
            Double($0.speed).rounded()
        }
    }
}
