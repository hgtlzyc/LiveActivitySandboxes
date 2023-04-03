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
    private let recentLocationsMaxRange: Int = 10
    
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
    
    var recentSpeedData: [WorkoutLiveActivityAttributes.SpeedInfo] {
        generateSpeedInfo(basedOn: recentLocations)
    }
    
    var minSpeedInRefRange: Double {
        vDSP.minimum(recentSpeeds)
    }
    
    var avgSpeed: Double {
        guard speeds.count > 1 else {
            return 0
        }
        return vDSP.mean(recentSpeeds)
    }
    
    var maxSpeedInRefRange: Double {
        guard speeds.count > 1 else {
            return 0
        }
        return vDSP.maximum(recentSpeeds)
    }
    
    //Helper
    private var speeds: [Double] {
        getSpeeds(basedOn: trackedLocations)
    }
    
    private var recentSpeeds: [Double] {
        getSpeeds(basedOn: recentLocations)
    }
    
    private var recentLocations: [CLLocation] {
        guard let trackedLocations else { return [] }
        return trackedLocations.suffix(recentLocationsMaxRange)
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
    
    //SpeedInfo Mapping
    func generateSpeedInfo(
        basedOn locations: [CLLocation]?
    ) -> [WorkoutLiveActivityAttributes.SpeedInfo] {
        guard let locations else {
            return []
        }
        return locations.map { location in
            WorkoutLiveActivityAttributes.SpeedInfo(
                date: location.timestamp,
                speed: location.speed
            )
        }
    }
}
