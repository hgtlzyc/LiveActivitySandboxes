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
    }
}
 
extension WorkoutLiveActivityView {
    var body: some View {
        VStack {
            HStack {
                Text("Duration:")
                Text(dateStarted, style: .timer)
                Spacer()
            }
            .font(.caption2)
            Chart {
                ForEach(state.speedData) { info in
                    LineMark(
                        x: .value("Date", info.date),
                        y: .value("Speed", info.speed)
                    )
                }
                
                RuleMark(y: .value("Speed", state.avgSpeed))
                    .foregroundStyle(.red)
                    .annotation(position: .top, alignment: .leading) {
                        Text("AVG: \(Int(state.avgSpeed)) mps")
                            .font(.body)
                            .foregroundColor(.orange)
                            .backgroundStyle(.gray)
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
        .activitySystemActionForegroundColor(Color.white)
        .padding()
    }
}

extension Double: Identifiable {
    public var id: String {
        return "\(self)"
    }
}

