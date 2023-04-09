//
//  WorkoutSpeedGraphDataProcessor.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 4/9/23.
//

import Accelerate
import CoreLocation

struct WorkoutSpeedGraphDataProcessor {
    
    init (
        trackedLocations: [CLLocation]?
    ) {
        
    }
    
}

//MARK: - Public Accessable
extension WorkoutSpeedGraphDataProcessor {
    var contentState: WorkoutLiveActivityAttributes.ContentState {
        return .emptyState
    }
}
