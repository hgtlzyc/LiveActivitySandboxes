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
                totalAVGSpeedText
                Text("Duration:")
                Text(dateStarted, style: .timer)
            }
            .font(.caption)
            
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
                
            }
            .chartXAxis(.hidden)
            .chartYScale(
                domain: Int(state.minSpeed)...Int(state.maxSpeed)
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

                    if let speed = value.as(Int.self) {
                        AxisValueLabel(
                            "\(speed) mps"
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

// MARK: - SubViews
private extension WorkoutLiveActivityView {
    var totalAVGSpeedText: Text {
        Text(
            "Total AVG: \(formattedDouble(state.avgSpeed)) mps"
        )
        .font(.subheadline.bold())
        .foregroundColor(.orange)
    }
}

// MARK: - Helpers
private extension WorkoutLiveActivityView {
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
