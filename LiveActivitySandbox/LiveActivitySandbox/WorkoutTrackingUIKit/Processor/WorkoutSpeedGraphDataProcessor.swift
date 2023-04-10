//
//  WorkoutSpeedGraphDataProcessor.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 4/9/23.
//

import Accelerate
import CoreLocation


//struct ContentState: Codable, Hashable {
//    var totalDistance: Double? = nil
//    var speedData: [SpeedInfo] = []
//
//    var trackedMinSpeed: Double = 0
//    var trackedAvgSpeed: Double = 0
//    var trackedMaxSpeed: Double = 0
//
//    var graphMinSpeed: Double = 0
//    var graphAvgSpeed: Double = 0
//    var graphMaxSpeed: Double = 0
//    var error: ErrorInfo? = nil
//}

class WorkoutSpeedGraphDataProcessor {
    //Properties
    //Due to ActicityKit Limitation, need limit data below 4kb
    //max will be 2 times this number
    static let targetFinalDataPoints: Int = 20
    
    //SOC
    private let trackedLocations: [CLLocation]?
    
    //Overall Info
    private lazy var totalDistance: Double? = {
        getTotolDistance(
            basedOn: trackedLocations
        )
    }()
    //For Tracked Speed Values
    private lazy var trackedSpeeds: [Double] = {
        getSpeeds(basedOn: trackedLocations)
    }()
    //For Speed Graph Drawning
    private lazy var chunkedSpeedInfos: [
        WorkoutLiveActivityAttributes.SpeedInfo
    ] = {
        generateChunkedSpeedInfo(
            basedOn: trackedLocations,
            targetFinalDataPoints: Self.targetFinalDataPoints
        )
    }()
    
    init (
        trackedLocations: [CLLocation]?
    ) {
        self.trackedLocations = trackedLocations
    }
}

//MARK: - Public Accessable
extension WorkoutSpeedGraphDataProcessor {
    func generateContentState(
    ) -> WorkoutLiveActivityAttributes.ContentState {
        guard let totalDistance else {
            return .emptyState
        }
        
        let trackSpeedInfo = getTrackMinAvgMax()
        let graphSpeedInfo = getGraphMinAvgMax()
        return .init(
            totalDistance: totalDistance,
            speedData: chunkedSpeedInfos,
            trackedMinSpeed: trackSpeedInfo.min,
            trackedAvgSpeed: trackSpeedInfo.avg,
            trackedMaxSpeed: trackSpeedInfo.max,
            graphMinSpeed: graphSpeedInfo.min,
            graphAvgSpeed: graphSpeedInfo.avg,
            graphMaxSpeed: graphSpeedInfo.max,
            error: nil
        )
    }
}

// MARK: - Helper
private extension WorkoutSpeedGraphDataProcessor {
    func getTrackMinAvgMax() -> (
        min: Double,
        avg: Double,
        max: Double
    ) {
        return getMinAvgMaxSpeeds(basedOn: trackedSpeeds)
    }
    
    func getGraphMinAvgMax() -> (
        min: Double,
        avg: Double,
        max: Double
    ) {
        let speedsForGraph = chunkedSpeedInfos.map(\.speed)
        return getMinAvgMaxSpeeds(basedOn: speedsForGraph)
    }
}

private extension WorkoutSpeedGraphDataProcessor {
    // MARK: - Distance Calculation
    func getTotolDistance(
        basedOn locations: [CLLocation]?
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
    
    // MARK: - Speed Calculations
    func getSpeeds(
        basedOn locations: [CLLocation]?
    ) -> [Double] {
        guard let locations else {
            return []
        }
        return locations.map {
            Double($0.speed)
        }
    }
    
    func getMinAvgMaxSpeeds(
        basedOn speeds: [Double]
    ) -> (Double, Double, Double) {
        let min = vDSP.minimum(speeds)
        let avg = vDSP.mean(speeds)
        let max = vDSP.maximum(speeds)
        return (min, avg, max)
    }
    
    // MARK: - Graph SpeedInfo Generation
    //max will be 2 times target(due to casting to int)
    func generateChunkedSpeedInfo(
        basedOn locations: [CLLocation]?,
        targetFinalDataPoints: Int
    ) -> [WorkoutLiveActivityAttributes.SpeedInfo] {
        guard let locations else {
            return []
        }
        
        guard locations.count > targetFinalDataPoints else {
            return locations.map { location in
                WorkoutLiveActivityAttributes.SpeedInfo(
                    date: location.timestamp,
                    speed: location.speed
                )
            }
        }
        let targetChunks = Int(locations.count / targetFinalDataPoints)
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
