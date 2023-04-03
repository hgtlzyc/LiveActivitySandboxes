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
    private let liveActivityTitle: String = "Speed Graph"
    private var liveActivity: Activity<WorkoutLiveActivityAttributes>?
    
    //Location Manager
    private let locationManager: LocationManager = LocationManager.shared
    
    //LiveActivity
    private let liveActivityUpdateDebounceInSecs: Double = 1
    private let liveActivityTrackingManager = WorkoutTrackingManager()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        createSubscriptions()
    }
}

//MARK: - Parent Accessable
extension WorkoutTrackingViewModel {
    
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
        
        Task {
            await liveActivityTrackingManager.addLocation(location)
            let contentState = await generateContentState(
                basedOn: liveActivityTrackingManager
            )
            if let liveActivity {
                await updateLiveActivity(
                    liveActivity,
                    with: contentState
                )
            } else {
                await endAllActivities()
                liveActivity = await generateNewActivity(
                    with: contentState,
                    title: liveActivityTitle
                )
            }
        }
    }
}

//MARK: - ContentState Generation
private extension WorkoutTrackingViewModel {
    func generateContentState(
        basedOn tracker: WorkoutTrackingManager
    ) async -> WorkoutLiveActivityAttributes.ContentState {
        WorkoutLiveActivityAttributes.ContentState(
            totalDistance: await tracker.totalDistance,
            speedData: await tracker.speedData,
            minSpeed: await tracker.minSpeed,
            avgSpeed: await tracker.avgSpeed,
            maxSpeed: await tracker.maxSpeed
        )
    }
}

// MARK: - LiveActivity Related
private extension WorkoutTrackingViewModel {
    var isLiveActivityAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    func generateNewActivity(
        with contentState: WorkoutLiveActivityAttributes.ContentState,
        title: String
    ) async -> Activity<WorkoutLiveActivityAttributes>? {
        guard isLiveActivityAvailable else {
            Log.error("live activity not enabled")
            return nil
        }
        
        let attributes = WorkoutLiveActivityAttributes(
            title: title,
            dateStarted: Date()
        )
        let activityContent = ActivityContent(
            state: contentState,
            staleDate: nil
        )
        return await MainActor.run {
            let newActivity: Activity<WorkoutLiveActivityAttributes>?
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
    }
    
    func updateLiveActivity(
        _ liveActivity: Activity<WorkoutLiveActivityAttributes>,
        with contentState: WorkoutLiveActivityAttributes.ContentState
    ) async {
        let content = ActivityContent(state: contentState, staleDate: nil)
        await liveActivity.update(content)
    }
    
    func endAllActivities() async {
        let finalState = WorkoutLiveActivityAttributes.ContentState.empthState
        let finalContent = ActivityContent(
            state: finalState, staleDate: nil
        )
        for activity in Activity<WorkoutLiveActivityAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
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
        
        //LiveActivity Sub
        locationManager
            .$location
            .print()
            .debounce(
                for: .seconds(liveActivityUpdateDebounceInSecs),
                scheduler: DispatchQueue.main
            )
            .sink { [weak self] location in
                self?.reactToLocationUpdate(location)
            }
            .store(in: &subscriptions)
    }
}
