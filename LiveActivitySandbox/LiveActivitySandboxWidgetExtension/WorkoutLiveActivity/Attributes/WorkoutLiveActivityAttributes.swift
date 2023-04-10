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
}

// MARK: - Main Model
extension WorkoutLiveActivityAttributes {
    struct ContentState: Codable, Hashable {
        var totalDistance: Double? = nil
        var speedData: [SpeedInfo] = []
        
        var trackedMinSpeed: Double = 0
        var trackedAvgSpeed: Double = 0
        var trackedMaxSpeed: Double = 0
        
        var graphMinSpeed: Double = 0
        var graphAvgSpeed: Double = 0
        var graphMaxSpeed: Double = 0
        var error: ErrorInfo? = nil
    }
}

//Helper
extension WorkoutLiveActivityAttributes.ContentState {
    static let emptyState: Self = .init()
    
    static func generateErrorState(
        with msg: String,
        at date: Date = Date()
    ) -> Self {
        .init(
            error: .init(
                message: msg,
                dateUpdated: date
            )
        )
    }
}

// MARK: - SubModels
extension WorkoutLiveActivityAttributes {
    struct SpeedInfo: Identifiable, Codable, Hashable {
        var date: Date
        var speed: Double
        var id: String {
            date.description
        }
    }
    
    struct ErrorInfo: Codable, Hashable {
        var message: String
        var dateUpdated: Date
    }
}
