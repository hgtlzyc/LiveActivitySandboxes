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
    let context: ActivityViewContext<WorkoutLiveActivityAttributes>
    
    private var upperBound: Int {
        context.state.value
    }
    
    private var demoNums: [Double] {
        Array(stride(from: 0.0, through: 3.5, by: 0.5))
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Workout Time:")
                Text("\(context.state.value)")
                Spacer()
            }
            .font(.caption2)
            Chart {
                ForEach(demoNums) { num in
                    LineMark(
                        x: .value("H", "\(num)"),
                        y: .value("V", num)
                    )
                }
                RuleMark(y: .value("V", 2))
                    .foregroundStyle(.red)
                    .annotation(position: .top, alignment: .leading) {
                        Text("AVG: 2 mps")
                            .font(.body)
                            .foregroundColor(.orange)
                    }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(values: [0, upperBound]) { value in
                     AxisGridLine(
                        stroke: StrokeStyle(
                            lineWidth: 1,
                            dash: [6, 3]
                        )
                     )
                     .foregroundStyle(.secondary)
                     
                    if let speed = value.as(Int.self) {
                        AxisValueLabel("\(speed) mps")
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

