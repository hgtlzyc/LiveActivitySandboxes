//
//  WorkoutTrackingManager.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/31/23.
//

import Accelerate
import CoreLocation

actor WorkoutTrackingManager {
    //Due to ActicityKit Limitation
    //max will be 1.5 times this num
    private let targetDataPointsAllowed: Int = 20
    
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
            return nil
        case let locations?:
            return getNonNegativeSpeedLocations(
                basedOn: locations
            )
        }
    }

    //Helper
    private func getNonNegativeSpeedLocations(
        basedOn locations: [CLLocation]
    ) -> [CLLocation] {
        locations.filter { location in
            location.speed >= 0
        }
    }
    
    nonisolated var maxDataTarget: Double {
        return Double(targetDataPointsAllowed) * 1.5
    }
    
    var totalDistance: Double? {
        totalDistanceInMetersBasedOn(
            trackedLocations
        )
    }
    
    var speedData: [WorkoutLiveActivityAttributes.SpeedInfo] {
        generateSpeedInfo(
            basedOn: trackedLocations,
            targetDataPointsAllowed: targetDataPointsAllowed
        )
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
    
    //Helper
    private var speeds: [Double] {
        speedData.map {
            max($0.speed, 0)
        }
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
    //max will be 1.5 times target(due to casting to int)
    func generateSpeedInfo(
        basedOn locations: [CLLocation]?,
        targetDataPointsAllowed: Int
    ) -> [WorkoutLiveActivityAttributes.SpeedInfo] {
        guard let locations else {
            return []
        }

        guard locations.count > targetDataPointsAllowed else {
            return locations.map { location in
                WorkoutLiveActivityAttributes.SpeedInfo(
                    date: location.timestamp,
                    speed: location.speed
                )
            }
        }
        let targetChunks = Int(locations.count / targetDataPointsAllowed)
        assert(targetChunks > 0)
        let finalChunks = targetChunks > 0 ? targetChunks : 1
        let processedLocations = locations.chunked(into: finalChunks)
        let processedSpeeds = processedLocations.map { subLocations in
            vDSP.mean(subLocations.map(\.speed))
        }
        let processedDates = processedLocations.map { subLocations in
            vDSP.mean(subLocations.map(\.timestamp.timeIntervalSince1970))
        }.map {
            Date(timeIntervalSince1970: $0)
        }
        
        let zipedSpeedInfo = zip(processedDates, processedSpeeds).map {
            WorkoutLiveActivityAttributes.SpeedInfo(
                date: $0,
                speed: max($1, 0)
            )
        }
        
        return zipedSpeedInfo
    }
}

fileprivate extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
