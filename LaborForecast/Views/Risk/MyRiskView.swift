//
//  MyRiskView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct MyRiskView: View {
    @Environment(OccupationService.self) var service
    @Environment(MyRiskViewModel.self) var viewModel
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil

    private var occupationsToShow: [Occupation] {
        var results = service.occupations
        if let cat = selectedCategory {
            results = results.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            results = results.filter { $0.title.lowercased().contains(q) }
        }
        return results.sorted { $0.title < $1.title }
    }

    private var showingList: Bool {
        !searchText.isEmpty || selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasSelection, let occupation = viewModel.selectedOccupation {
                    scoreState(occupation)
                } else {
                    emptyState
                }
            }
            .navigationTitle("My Risk")
            .navigationDestination(for: Occupation.self) { occupation in
                CareerDetailView(occupation: occupation)
            }
        }
        .onAppear {
            viewModel.load(from: service)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("What's your occupation?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search your job title…", text: $searchText)
                    .autocorrectionDisabled()
                    .onChange(of: searchText) { _, _ in
                        if !searchText.isEmpty { selectedCategory = nil }
                    }
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color.primary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.bottom, 12)

            // Category breadcrumb when a category is selected
            if let cat = selectedCategory {
                HStack {
                    Button {
                        selectedCategory = nil
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.caption)
                            Text(categoryDisplayName(cat))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(Color.LFGreen)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            if showingList {
                // Filtered occupation list
                if occupationsToShow.isEmpty {
                    Spacer()
                    Text("No results")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(occupationsToShow) { occupation in
                                Button {
                                    viewModel.select(occupation)
                                    searchText = ""
                                    selectedCategory = nil
                                } label: {
                                    OccupationCard(occupation: occupation)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            } else {
                // Category grid
                Text("BROWSE BY CATEGORY")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                ScrollView {
                    inlineCategoryGrid
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    private var inlineCategoryGrid: some View {
        let grouped = Dictionary(grouping: service.occupations, by: \.category)
        let categories = grouped.keys.sorted()
        let columns = [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories, id: \.self) { slug in
                let occupation = grouped[slug] ?? []
                let avg = Double(occupation.map(\.exposure).reduce(0, +)) / Double(max(occupation.count, 1))
                Button {
                    selectedCategory = slug
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(categoryDisplayName(slug))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .foregroundStyle(.primary)
                        Text("\(occupation.count) careers")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.primary.opacity(0.08))
                                    .frame(height: 3)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(riskColor(for: Int(avg.rounded())))
                                    .frame(width: geo.size.width * CGFloat(avg) / 10, height: 3)
                            }
                        }
                        .frame(height: 3)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Score state

    private func scoreState(_ occupation: Occupation) -> some View {
        let saferAlts = service.saferAlternatives(for: occupation)
        let all = service.occupations
        let percentile = all.isEmpty ? 0 : Int(Double(all.filter { $0.exposure >= occupation.exposure }.count) / Double(all.count) * 100)

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Selected job pill
                HStack {
                    TierBadge(tier: occupation.aiTier)
                    Text(occupation.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)

                // Score card
                VStack(spacing: 12) {
                    HStack(alignment: .bottom, spacing: 24) {
                        RiskGauge(score: occupation.exposure)
                            .frame(width: 130, height: 70)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(tierLabel(for: occupation.aiTier)) exposure")
                                .font(.headline)
                                .foregroundStyle(tierColor(for: occupation.aiTier))
                            Text("Top \(percentile)% of all occupations")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            LinearGradient(
                                colors: [.riskMinimal, .riskLow, .riskModerate, .riskHigh, .riskVeryHigh],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .frame(height: 8)
                            Circle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                                .shadow(radius: 2)
                                .offset(x: geo.size.width * CGFloat(occupation.exposure) / 10 - 8)
                        }
                    }
                    .frame(height: 16)
                }
                .padding()
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // AI reason
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
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                }

                // Safer transitions
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
            .padding(.vertical)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Change") {
                    viewModel.clear()
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
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
