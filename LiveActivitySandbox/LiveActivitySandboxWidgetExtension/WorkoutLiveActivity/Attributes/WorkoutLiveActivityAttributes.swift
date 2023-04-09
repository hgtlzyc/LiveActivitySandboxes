//
//  WorkoutLiveActivityAttributes.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 4/1/23.
//

import Foundation
import ActivityKit

struct WorkoutLiveActivityAttributes: ActivityAttributes {
    var title: String
    var dateStarted: Date
    public struct ContentState: Codable, Hashable {
        var totalDistance: Double?
        var speedData: [SpeedInfo]
        
        var trackedMinSpeed: Double
        var trackedAvgSpeed: Double
        var trackedMaxSpeed: Double
        
        var graphMinSpeed: Double
        var graphAvgSpeed: Double
        var graphMaxSpeed: Double
        
        static let emptyState: Self = ContentState(
            totalDistance: nil,
            speedData: [],
            trackedMinSpeed: 0,
            trackedAvgSpeed: 0,
            trackedMaxSpeed: 0,
            graphMinSpeed: 0,
            graphAvgSpeed: 0,
            graphMaxSpeed: 0
        )
    }
}

extension WorkoutLiveActivityAttributes {
    struct SpeedInfo: Identifiable, Codable, Hashable {
        var date: Date
        var speed: Double
        var id: String {
            date.description
        }
    }
}
