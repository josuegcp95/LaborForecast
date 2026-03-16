//
//  CareerDetailView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct CareerDetailView: View {
    let occupation: Occupation

    @Environment(OccupationService.self) var service
    @Environment(FavoritesViewModel.self) var favorites

    private var saferAlts: [Occupation] {
        service.saferAlternatives(for: occupation)
    }

    private var percentile: Int {
        let all = service.occupations
        guard !all.isEmpty else { return 0 }
        let above = all.filter { $0.exposure >= occupation.exposure }.count
        return Int(Double(above) / Double(all.count) * 100)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(occupation.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(categoryDisplayName(occupation.category))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Score card
                scoreCard

                // Stats grid
                statsGrid

                // Why exposed
                whySection

                // Safer transitions
                saferSection
            }
            .padding(.vertical)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favorites.toggle(occupation.slug)
                } label: {
                    Image(systemName: favorites.isSaved(occupation.slug) ? "heart.fill" : "heart")
                        .foregroundStyle(favorites.isSaved(occupation.slug) ? .red : .primary)
                }
            }
        }
    }

    // MARK: - Score Card

    private var scoreCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 24) {
                RiskGauge(score: occupation.exposure)
                    .frame(width: 130, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tierLabel(for: occupation.aiTier) + " exposure")
                        .font(.headline)
                        .foregroundStyle(tierColor(for: occupation.aiTier))
                    Text("Top \(percentile)% of all occupations")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // Gradient risk bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    LinearGradient(
                        colors: [.riskMinimal, .riskLow, .riskModerate, .riskHigh, .riskVeryHigh],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(height: 8)

                    // Marker
                    let x = geo.size.width * CGFloat(occupation.exposure) / 10
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .shadow(radius: 2)
                        .offset(x: x - 8)
                }
            }
            .frame(height: 16)
        }
        .padding()
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCell(label: "Median Pay (2024)", value: formatPay(occupation.pay))
            statCell(label: "Jobs (2024)", value: formatJobs(occupation.jobs))
            statCell(label: "Outlook (10-yr)", value: formatOutlook(occupation.outlook))
            statCell(label: "Education", value: occupation.education)
        }
        .padding(.horizontal)
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Why Section

    private var whySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHY \(tierLabel(for: occupation.aiTier).uppercased()) EXPOSURE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(1.5)
                .padding(.horizontal)

            Text(occupation.aiReason)
                .font(.body)
                .padding()
                .background(cardBG)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
        }
    }

    // MARK: - Safer Transitions

    private var saferSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SAFER TRANSITIONS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(1.5)
                .padding(.horizontal)

            if saferAlts.isEmpty {
                Text("This career is already among the most AI-resistant.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(saferAlts) { alt in
                            NavigationLink(value: alt) {
                                altCard(alt)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func altCard(_ alt: Occupation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TierBadge(tier: alt.aiTier)
            Text(alt.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.primary)
            Text(formatPay(alt.pay))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 160, height: 120, alignment: .topLeading)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private var cardBG: Color {
        Color.primary.opacity(0.05)
    }
}
