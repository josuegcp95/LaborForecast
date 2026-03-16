//
//  ExploreView.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

struct ExploreView: View {
    @Environment(OccupationService.self) var service
    @State private var viewModel = ExploreViewModel()
    @State private var showCategories = false
    @State private var showSettings = false
    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath) {
            VStack(spacing: 0) {
                // Custom subtitle under nav title
                HStack {
                    Text("341 occupations · 143M jobs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 8)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search occupations…", text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.updateSearch($0) }
                    ))
                    .autocorrectionDisabled()
                    if !viewModel.searchText.isEmpty {
                        Button { viewModel.updateSearch("") } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Filter chips
                filterChips

                Divider()

                // List content
                ScrollView {
                    LazyVStack(spacing: 12, pinnedViews: []) {
                        if viewModel.isSearching {
                            filteredContent
                        } else {
                            defaultSections
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showCategories = true
                    } label: {
                        Label("Categories", systemImage: "square.grid.2x2")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: Occupation.self) { occ in
                CareerDetailView(occupation: occ)
            }
            .sheet(isPresented: $showCategories) {
                CategoriesView { slug in
                    viewModel.setCategory(slug)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .onAppear {
            if !service.isLoaded { return }
            viewModel.load(from: service)
        }
        .onChange(of: service.isLoaded) { _, loaded in
            if loaded { viewModel.load(from: service) }
        }
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip("All", filter: .all)
                filterChip("Low risk", filter: .lowRisk)
                filterChip("High risk", filter: .highRisk)
                filterChip("$75k+", filter: .highPay)
                filterChip("No degree", filter: .noDegree)

                if viewModel.activeCategory != nil {
                    Button {
                        viewModel.setCategory(nil)
                    } label: {
                        HStack(spacing: 4) {
                            Text(categoryDisplayName(viewModel.activeCategory ?? ""))
                                .font(.caption)
                            Image(systemName: "xmark")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.LFGreen.opacity(0.2))
                        .foregroundStyle(Color.LFGreen)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func filterChip(_ label: String, filter: ExploreFilter) -> some View {
        let isActive = viewModel.activeFilter == filter
        return Button {
            viewModel.setFilter(filter)
        } label: {
            Text(label)
                .font(.caption)
                .fontWeight(isActive ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isActive ? Color.LFGreen.opacity(0.2) : Color.primary.opacity(0.06))
                .foregroundStyle(isActive ? Color.LFGreen : Color.primary)
                .clipShape(Capsule())
        }
    }

    // MARK: - Default sections

    private var defaultSections: some View {
        Group {
            sectionHeader("MOST AT RISK")
            ForEach(viewModel.mostAtRisk) { occ in
                NavigationLink(value: occ) {
                    OccupationCard(occupation: occ)
                }
                .buttonStyle(.plain)
            }

            sectionHeader("MOST AI-PROOF")
            ForEach(viewModel.mostAIProof) { occ in
                NavigationLink(value: occ) {
                    OccupationCard(occupation: occ)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Filtered content

    private var filteredContent: some View {
        Group {
            if viewModel.filteredOccupations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No results")
                        .font(.headline)
                    Text("Try a different search or filter.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(viewModel.filteredOccupations) { occ in
                    NavigationLink(value: occ) {
                        OccupationCard(occupation: occ)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(1.5)
            Spacer()
        }
    }
}
