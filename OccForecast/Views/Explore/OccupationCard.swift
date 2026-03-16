import SwiftUI

struct OccupationCard: View {
    let occupation: Occupation
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title + badge row
            HStack(alignment: .top) {
                Text(occupation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                Spacer()
                TierBadge(tier: occupation.aiTier)
            }

            // Subtitle
            Text("\(categoryDisplayName(occupation.category)) · \(formatJobs(occupation.jobs)) jobs")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Stats row
            HStack(spacing: 0) {
                statItem(label: "Salary", value: formatPay(occupation.pay))
                Divider().frame(height: 24).padding(.horizontal, 8)
                statItem(label: "Growth", value: formatOutlook(occupation.outlook))
                Divider().frame(height: 24).padding(.horizontal, 8)
                statItem(label: "Edu", value: shortEdu(occupation.education))
            }

            // Risk bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(riskColor(for: occupation.exposure))
                        .frame(width: geo.size.width * CGFloat(occupation.exposure) / 10, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private var cardBackground: Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.white
    }

    private var cardBorder: Color {
        colorScheme == .dark ? Color.white.opacity(0.09) : Color.black.opacity(0.07)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func shortEdu(_ edu: String) -> String {
        if edu.lowercased().contains("bachelor") { return "Bachelor's" }
        if edu.lowercased().contains("master") { return "Master's" }
        if edu.lowercased().contains("doctoral") || edu.lowercased().contains("professional") { return "Doctoral" }
        if edu.lowercased().contains("associate") { return "Associate's" }
        if edu.lowercased().contains("high school") { return "HS Diploma" }
        if edu.lowercased().contains("certificate") { return "Certificate" }
        if edu.lowercased().contains("no degree") { return "No Degree" }
        return edu
    }
}
