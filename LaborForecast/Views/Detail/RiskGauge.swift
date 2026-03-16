//
//  RiskGauge.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct RiskGauge: View {
    
    @State private var progress: Double = 0
    let score: Int
    var animated: Bool = true

    var body: some View {
        ZStack {
            // Track arc
            Arc(startAngle: .degrees(180), endAngle: .degrees(360))
                .stroke(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 10, lineCap: .round))

            // Fill arc
            Arc(startAngle: .degrees(180), endAngle: .degrees(180 + 180 * progress))
                .stroke(riskColor(for: score), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .animation(animated ? .easeOut(duration: 0.8) : .none, value: progress)

            // Score text
            VStack(spacing: 2) {
                Spacer()
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(riskColor(for: score))
                Text("/ 10")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 4)
        }
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.8)) {
                    progress = Double(score) / 10
                }
            } else {
                progress = Double(score) / 10
            }
        }
        .onChange(of: score) { _, newScore in
            if animated {
                withAnimation(.easeOut(duration: 0.8)) {
                    progress = Double(newScore) / 10
                }
            } else {
                progress = Double(newScore) / 10
            }
        }
    }
}

private struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width, rect.height * 2) / 2
        path.addArc(center: center, radius: radius,
                    startAngle: startAngle, endAngle: endAngle,
                    clockwise: false)
        return path
    }
}
