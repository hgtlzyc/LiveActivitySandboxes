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
    //SOC
    private let dateStarted: Date
    private var state: WorkoutLiveActivityAttributes.ContentState
    
    //Visual
    private let plotInterpolationMethod: InterpolationMethod = .monotone
    
    init(context: ActivityViewContext<WorkoutLiveActivityAttributes>) {
        self.dateStarted = context.attributes.dateStarted
        self.state = context.state
        if state.minSpeed > state.maxSpeed {
            state.minSpeed = state.maxSpeed
        }
        Log.debug("init finished")
    }
}

extension WorkoutLiveActivityView {
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                [
                Text("Duration: "),
                durationText,
                distanceText
                ].reduce(Text(""), +)
            }
            .foregroundColor(.gray)
            .font(.caption.bold())
            .monospacedDigit()
            
            Chart {
                ForEach(state.speedData) { info in
                    LineMark(
                        x: .value("Date", info.date),
                        y: .value("Speed", info.speed)
                    )
                    .lineStyle(
                        .init(
                            lineWidth: 1,
                            dash: [6,3]
                        )
                    )
                    .foregroundStyle(.white.opacity(0.5))
                    .interpolationMethod(plotInterpolationMethod)
                }
                
                RuleMark(
                    y: .value("Total Avg Speed", state.avgSpeed)
                )
                .foregroundStyle(.red.opacity(0.6))
                .annotation(
                    position: .overlay,
                    alignment: .bottomTrailing
                ) {
                    Text(
                        Self.formattedString(
                            state.avgSpeed,
                            unit: UnitSpeed.metersPerSecond
                        )
                    )
                    .font(.body.bold())
                    .foregroundColor(.white)
                }
            }
            .chartXAxis(.hidden)
            .chartYScale(
                domain: state.minSpeed...state.maxSpeed
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
                    .foregroundStyle(.clear)

                    if let speed = value.as(Double.self) {
                        AxisValueLabel(
                            Self.formattedString(
                                speed,
                                unit: UnitSpeed.metersPerSecond,
                                numberOfFractions: 1
                            )
                        )
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .activityBackgroundTint(Color.black)
        .foregroundColor(.white)
        .padding()
    }
}

// MARK: - SubViews
private extension WorkoutLiveActivityView {
    var durationText: Text {
        Text(dateStarted, style: .relative)
            .foregroundColor(.white)
    }
    
    var distanceText: Text {
        guard let distanceValue = state.totalDistance else {
            return Text("-")
        }
        let distanceString = Self.formattedString(
            distanceValue,
            unit: UnitLength.meters,
            numberOfFractions: 0,
            unitStyle: .medium
        )
        let distanceText = Text(
            distanceString
        )
        .foregroundColor(.white)
        
        return Text("  Distance: ") + distanceText
    }
}

// MARK: - Shared Helpers
extension WorkoutLiveActivityView {
    static func formattedString(
        _ baseValue: Double,
        unit: Unit,
        numberOfFractions: Int = 2,
        unitStyle: Formatter.UnitStyle = .short
    ) -> String {
        let mpsMeasurement = Measurement(
            value: baseValue,
            unit: unit
        )
        let formatter = MeasurementFormatter()
        formatter.numberFormatter = numberFormatter(
            numberOfFractions: numberOfFractions
        )
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = unitStyle
        return formatter.string(from: mpsMeasurement)
    }
    
    
    static func numberFormatter(
        numberOfFractions: Int
    ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = numberOfFractions
        formatter.maximumFractionDigits = numberOfFractions
        return formatter
    }
}
