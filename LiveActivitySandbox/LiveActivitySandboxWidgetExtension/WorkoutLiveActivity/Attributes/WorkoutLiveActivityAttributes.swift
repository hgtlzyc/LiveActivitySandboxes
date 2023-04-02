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
        var minSpeed: Double
        var avgSpeed: Double
        var maxSpeed: Double
        
        static let empthState: Self = ContentState(
            totalDistance: 0,
            speedData: [],
            minSpeed: 0,
            avgSpeed: 0,
            maxSpeed: 0
        )
    }
}

extension WorkoutLiveActivityAttributes {
    struct SpeedInfo: Identifiable, Codable, Hashable {
        var date: Date
        var speed: Double
        var id: String {
            date.description + String(speed)
        }
    }
}
