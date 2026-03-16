import Foundation
import Observation

@Observable
class MyRiskViewModel {
    var selectedSlug: String = UserDefaults.standard.string(forKey: "selectedSlug") ?? ""
    var selectedOccupation: Occupation?

    var hasSelection: Bool { !selectedSlug.isEmpty }

    private var service: OccupationService?

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
