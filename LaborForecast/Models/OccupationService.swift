//
//  OccupationService.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import Foundation
import Observation

@Observable
class OccupationService {
    
    var occupations: [Occupation] = []
    var isLoaded = false

    private var slugIndex: [String: Occupation] = [:]

    init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "labor_forecast_data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Occupation].self, from: data)
        else { return }
        occupations = decoded
        slugIndex = Dictionary(uniqueKeysWithValues: decoded.map { ($0.slug, $0) })
        isLoaded = true
    }

    func occupation(for slug: String) -> Occupation? {
        slugIndex[slug]
    }

    func saferAlternatives(for occupation: Occupation) -> [Occupation] {
        occupation.saferAlts.compactMap { slugIndex[$0] }
    }
}
