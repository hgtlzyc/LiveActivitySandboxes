//
//  WorkoutTrackingViewModel.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 3/30/23.
//

import UIKit
import Combine
import ActivityKit
import CoreLocation
import MapKit

class WorkoutTrackingViewModel: NSObject {
    // MARK: - Properties
    //LiveActivities
    private let liveActivityName: String = "kWorkoutLiveActivity"
    private var liveActivity: Activity<WorkoutLiveActivityAttributes>?
    
    //Location Manager
    private let locationUpdateDebounceInSecs: Double = 0.5
    private lazy var locationManager: LocationManager = {
        LocationManager.shared
    }()
    
    //Combine
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Demo Only
    private var demoCounter: Int = 0
    
    override init() {
        super.init()
        createSubscriptions()
    }
}

// MARK: - LoicationManager Reactions
private extension WorkoutTrackingViewModel {
    func reactToAuthState(_ state: CLAuthorizationStatus?) {
        guard let state else {
            Log.info("waiting for location auth status update")
            return
        }
        
        switch state {
        case .notDetermined:
            locationManager.requestAlwaysAuth()
        case .authorizedAlways:
            locationManager.startUpdates()
        case .restricted, .denied, .authorizedWhenInUse:
            assertionFailure("needs always auth for demo")
        case .authorized:
            assertionFailure("unexpected state for iOS")
        @unknown default:
            assertionFailure("unexpected state")
        }
    }
    
    func reactToLocationUpdate(_ location: CLLocation?) {
        guard let location else {
            Log.info("waiting for location value update")
            return
        }
        Log.debug("\(location)")
        if let liveActivity {
            demoCounter += 1
            updateLiveActivity(
                liveActivity,
                with: demoCounter
            )
        } else {
            liveActivity = generateNewActivity(
                with: demoCounter,
                name: liveActivityName
            )
        }
        
    }
}

// MARK: - LiveActivity Related
private extension WorkoutTrackingViewModel {
    var isLiveActivityAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    func generateNewActivity(
        with value: Int,
        name: String
    ) -> Activity<WorkoutLiveActivityAttributes>? {
        guard isLiveActivityAvailable else {
            Log.error("live activity not enabled")
            return nil
        }
        let newActivity: Activity<WorkoutLiveActivityAttributes>?
        
        let attributes = WorkoutLiveActivityAttributes(name: name)
        let initialContentState = WorkoutLiveActivityAttributes.ContentState(
            value: value
        )
        let activityContent = ActivityContent(
            state: initialContentState,
            staleDate: nil
        )
        
        do {
            newActivity = try Activity.request(
                attributes: attributes,
                content: activityContent
            )
        } catch (let err ){
            Log.error(err.localizedDescription)
            newActivity = nil
        }
        
        return newActivity
    }
    
    func updateLiveActivity(
        _ liveActivity: Activity<WorkoutLiveActivityAttributes>,
        with value: Int
    ) {
        let contentState = WorkoutLiveActivityAttributes.ContentState(
            value: value
        )
        let content = ActivityContent(
            state: contentState, staleDate: nil
        )
        
        Task {
            await liveActivity.update(content)
        }
    }
    
}

// MARK: - Setup
private extension WorkoutTrackingViewModel {
    func createSubscriptions() {
        locationManager
            .$authStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.reactToAuthState(state)
            }
            .store(in: &subscriptions)
        
        locationManager
            .$location
            .debounce(
                for: .seconds(locationUpdateDebounceInSecs),
                scheduler: DispatchQueue.main
            )
            .sink { [weak self] location in
                self?.reactToLocationUpdate(location)
            }
            .store(in: &subscriptions)
    }
}
