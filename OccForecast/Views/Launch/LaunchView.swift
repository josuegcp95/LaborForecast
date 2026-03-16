import SwiftUI

struct LaunchView: View {
    let onFinish: () -> Void

    @Environment(OccupationService.self) var occupationService
    @State private var barsVisible = [false, false, false, false, false, false, false]
    @State private var titleVisible = false
    @State private var subtitleVisible = false

    private let barColors: [Color] = [
        .riskMinimal, .riskMinimal,
        .riskLow,
        .riskModerate,
        .riskHigh,
        .riskVeryHigh, .riskVeryHigh
    ]

    var body: some View {
        ZStack {
            Color.occDarkBG.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Animated bars
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColors[i])
                            .frame(width: 28, height: barHeight(for: i))
                            .opacity(barsVisible[i] ? 1 : 0)
                            .scaleEffect(y: barsVisible[i] ? 1 : 0.1, anchor: .bottom)
                    }
                }
                .frame(height: 120)

                Spacer().frame(height: 28)

                // "OCCUPATIONAL"
                Text("OCCUPATIONAL")
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .tracking(8)
                    .opacity(titleVisible ? 1 : 0)

                // "FORECAST"
                Text("FORECAST")
                    .font(.system(size: 18, weight: .light, design: .default))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(12)
                    .opacity(subtitleVisible ? 1 : 0)

                Spacer()

                ProgressView()
                    .tint(.white.opacity(0.4))
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            animateBars()
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let heights: [CGFloat] = [48, 72, 88, 100, 88, 64, 44]
        return heights[index]
    }

    private func animateBars() {
        for i in 0..<7 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.1)) {
                barsVisible[i] = true
            }
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.8)) {
            titleVisible = true
        }
        withAnimation(.easeIn(duration: 0.4).delay(1.0)) {
            subtitleVisible = true
        }

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            onFinish()
        }
    }
}
