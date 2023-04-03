//
//  WorkoutLiveActivityView.swift
//  LiveActivitySandbox
//
//  Created by lijia xu on 4/2/23.
//

import SwiftUI
import WidgetKit
import Charts

struct WorkoutLiveActivityView: View {
    
    private let dateStarted: Date
    private let state: WorkoutLiveActivityAttributes.ContentState
    
    init(context: ActivityViewContext<WorkoutLiveActivityAttributes>) {
        self.dateStarted = context.attributes.dateStarted
        self.state = context.state
        Log.debug("init finished")
    }
}

extension WorkoutLiveActivityView {
    var body: some View {
        VStack {
            HStack {
                Text("Duration:")
                Text(dateStarted, style: .timer)
            }
            .font(.caption)
            .monospacedDigit()
            
            Chart {
                ForEach(state.speedData) { info in
                    LineMark(
                        x: .value("Date", info.date),
                        y: .value("Speed", info.speed)
                    )
                    .foregroundStyle(.white.opacity(0.5))
                }
                
                RuleMark(
                    y: .value("Total Avg Speed", state.avgSpeed)
                )
                .foregroundStyle(.red)
                .annotation {
                    Text(
                        "Total AVG: " + formattedSpeedString(state.avgSpeed)
                    )
                    .font(.body.bold())
                    .foregroundColor(.orange)
                }
                
            }
            .chartXAxis(.hidden)
            .chartYScale(
                domain: ceil(state.minSpeed)...floor(state.maxSpeed)
            )
            .chartYAxis {
                AxisMarks(
                    values: [
                        state.minSpeed, state.maxSpeed
                    ]
                ) { value in
                    AxisGridLine(
                        stroke: StrokeStyle(
                            lineWidth: 1,
                            dash: [6, 3]
                        )
                    )
                    .foregroundStyle(.secondary)

                    if let speed = value.as(Double.self) {
                        AxisValueLabel(
                            formattedSpeedString(speed)
                        )
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .activityBackgroundTint(Color.black)
        .foregroundColor(.white)
        .padding()
        .transaction { trans in
            trans.animation = nil
        }
    }
}

// MARK: - Helpers
private extension WorkoutLiveActivityView {
    func formattedSpeedString(
        _ mpsValue: Double
    ) -> String {
        let mpsMeasurement = Measurement(
            value: mpsValue,
            unit: UnitSpeed.metersPerSecond
        )
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        return formatter.string(from: mpsMeasurement)
    }
    
    
    func formattedDouble(
        _ value: Double,
        numberOfFractions: Int = 2
    ) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = numberOfFractions
        formatter.maximumFractionDigits = numberOfFractions
        guard let doubleString = formatter.string(
            from: value as NSNumber
        ) else {
            Log.error("unable formatt value: \(value)")
            return "\(Int(value))"
        }
        return doubleString
    }
}
