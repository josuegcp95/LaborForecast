//
//  FavoritesViewModel.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI
import Observation

@Observable
class FavoritesViewModel {
    
    private var service: OccupationService?
    private(set) var savedSlugs: [String]

    init() {
        let raw = UserDefaults.standard.string(forKey: "savedSlugs") ?? ""
        savedSlugs = raw.isEmpty ? [] : raw.components(separatedBy: ",")
    }

    var savedOccupations: [Occupation] {
        guard let service else { return [] }
        return savedSlugs.compactMap { service.occupation(for: $0) }
    }

    func load(from service: OccupationService) {
        self.service = service
    }

    func toggle(_ slug: String) {
        if isSaved(slug) {
            remove(slug)
        } else {
            savedSlugs.append(slug)
            persist()
        }
    }

    func isSaved(_ slug: String) -> Bool {
        savedSlugs.contains(slug)
    }

    func remove(_ slug: String) {
        savedSlugs.removeAll { $0 == slug }
        persist()
    }

    func move(from source: IndexSet, to destination: Int) {
        savedSlugs.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(savedSlugs.joined(separator: ","), forKey: "savedSlugs")
    }
}
