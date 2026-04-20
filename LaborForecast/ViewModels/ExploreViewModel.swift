//
//  ExploreViewModel.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import Foundation
import Observation

enum ExploreFilter: Equatable {
    case all, topTen, lowRisk, highRisk, highPay, highPayPlus, noDegree
}

@Observable
class ExploreViewModel {
    
    var searchText = ""
    var activeFilter: ExploreFilter = .topTen
    var activeCategory: String? = nil

    private var allOccupations: [Occupation] = []
    private(set) var filteredOccupations: [Occupation] = []
    private(set) var mostAtRisk: [Occupation] = []
    private(set) var mostAIProof: [Occupation] = []

    var isSearching: Bool {
        !searchText.isEmpty || activeFilter != .topTen || activeCategory != nil
    }

    private var searchTask: Task<Void, Never>?

    func load(from service: OccupationService) {
        allOccupations = service.occupations
        mostAtRisk = Array(allOccupations.sorted { $0.exposure > $1.exposure }.prefix(5))
        mostAIProof = Array(allOccupations.sorted { $0.exposure < $1.exposure }.prefix(5))
        applyFilters()
    }

    func updateSearch(_ text: String) {
        searchText = text
        scheduleFilter()
    }

    func setFilter(_ filter: ExploreFilter) {
        activeFilter = filter
        if filter == .topTen { activeCategory = nil }
        applyFilters()
    }

    func setCategory(_ category: String?) {
        activeCategory = category
        if category != nil { activeFilter = .all }
        applyFilters()
    }

    private func scheduleFilter() {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            applyFilters()
        }
    }

    private func applyFilters() {
        var results = allOccupations

        if let cat = activeCategory {
            results = results.filter { $0.category == cat }
        }

        switch activeFilter {
        case .all, .topTen: break
        case .lowRisk:      results = results.filter { $0.exposure <= 3 }
        case .highRisk:     results = results.filter { $0.exposure >= 7 }
        case .highPay:      results = results.filter { ($0.pay ?? 0) >= 75_000 }
        case .highPayPlus:  results = results.filter { ($0.pay ?? 0) >= 100_000 }
        case .noDegree:
            results = results.filter {
                let edu = $0.education.lowercased()
                return edu.contains("no degree") || edu.contains("high school") || edu.contains("certificate")
            }
        }

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            results = results.filter { $0.title.lowercased().contains(q) }
        }

        if activeFilter == .highPayPlus {
            filteredOccupations = results.sorted { ($0.pay ?? 0) > ($1.pay ?? 0) }
        } else {
            filteredOccupations = results.sorted { $0.title < $1.title }
        }
    }
}
