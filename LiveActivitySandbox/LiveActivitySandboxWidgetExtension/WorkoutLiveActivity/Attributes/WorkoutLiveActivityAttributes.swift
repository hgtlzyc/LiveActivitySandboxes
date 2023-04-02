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
        var totalDistance: Double
        var speeds: [Double]
        var minSpeed: Double
        var avgSpeed: Double
        var maxSpeed: Double
    }
}
