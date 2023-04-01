//
//  WorkoutLiveActivityAttributes.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 4/1/23.
//

import ActivityKit

struct WorkoutLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var value: Int
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
