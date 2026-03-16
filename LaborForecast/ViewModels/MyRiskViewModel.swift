//
//  MyRiskViewModel.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import Foundation
import Observation

@Observable
class MyRiskViewModel {
    
    var selectedOccupation: Occupation?
    private var service: OccupationService?
    var selectedSlug: String = UserDefaults.standard.string(forKey: "selectedSlug") ?? ""
    var hasSelection: Bool { !selectedSlug.isEmpty }

    func load(from service: OccupationService) {
        self.service = service
        resolve()
    }

    func select(_ occupation: Occupation) {
        selectedSlug = occupation.slug
        UserDefaults.standard.set(occupation.slug, forKey: "selectedSlug")
        selectedOccupation = occupation
    }

    func clear() {
        selectedSlug = ""
        UserDefaults.standard.removeObject(forKey: "selectedSlug")
        selectedOccupation = nil
    }

    private func resolve() {
        guard !selectedSlug.isEmpty, let service else {
            selectedOccupation = nil
            return
        }
        selectedOccupation = service.occupation(for: selectedSlug)
    }
}
