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
    
    @Published var infoString: String = ""
    
    //LiveActivity
    private let liveActivityUpdateDebounceInSecs: Double = 2
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
        typealias ContentState = WorkoutLiveActivityAttributes.ContentState
        Task {
            let contentState: ContentState
            if let location {
                await liveActivityTrackingManager.addLocation(location)
                contentState = await generateContentState(
                    basedOn: liveActivityTrackingManager
                )
                self.infoString = generateInfoString(basedOn: contentState)
            } else {
                let infoString = "waiting for location value update"
                Log.info(infoString)
                contentState = ContentState.empthState
                self.infoString = infoString
            }
            if let liveActivity {
                await updateLiveActivity(
                    liveActivity,
                    with: contentState
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
    ) -> Activity<WorkoutLiveActivityAttributes>? {
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
    
    func updateLiveActivity(
        _ liveActivity: Activity<WorkoutLiveActivityAttributes>,
        with contentState: WorkoutLiveActivityAttributes.ContentState
    ) async {
        let content = ActivityContent(
            state: contentState,
            staleDate: nil
        )
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
        Log.info("End Previous Activities")
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
        
        //For Fast Demo
        typealias ContentState = WorkoutLiveActivityAttributes.ContentState
        Task {
            await endAllActivities()
            liveActivity = generateNewActivity(
                with: ContentState.empthState,
                title: liveActivityTitle
            )
        }
        
        //LiveActivity Sub
        locationManager
            .$location
            .print()
            .throttle(
                for: .seconds(liveActivityUpdateDebounceInSecs),
                scheduler: DispatchQueue.main,
                latest: true)
            .sink { [weak self] location in
                self?.reactToLocationUpdate(location)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Info Helper For Fast Demo
private extension WorkoutTrackingViewModel {
    typealias DemoHelper = WorkoutLiveActivityView
    
    func generateInfoString(
        basedOn content: WorkoutLiveActivityAttributes.ContentState
    ) -> String {
        let distance = DemoHelper.formattedString(
            content.totalDistance ?? 0,
            unit: UnitLength.meters,
            numberOfFractions: 0,
            unitStyle: .long
        )
        let minSpeedInfo = speedInfo(content.minSpeed)
        let avgSpeedInfo = speedInfo(content.avgSpeed)
        let maxSpeedInfo = speedInfo(content.maxSpeed)
        let targetMaxDataPoints = Int(
            ceil(liveActivityTrackingManager.maxDataTarget)
        )
        
        return [
            "Total Distance: \(distance)",
            "AVG: \(avgSpeedInfo)",
            "min:\(minSpeedInfo)",
            "max: \(maxSpeedInfo)",
            "",
            "Target Max Data Points: \(targetMaxDataPoints)",
            "Data Points Count: \(content.speedData.count)"
        ].joined(separator: "\n")
    }
    
    //Helper
    func speedInfo(_ value: Double) -> String {
        DemoHelper.formattedString(
            value,
            unit: UnitSpeed.metersPerSecond,
            numberOfFractions: 2,
            unitStyle: .long
        )
    }
}
