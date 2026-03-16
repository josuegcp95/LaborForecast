import SwiftUI

@main
struct OccForecastApp: App {
    @State private var occupationService = OccupationService()
    @State private var favoritesViewModel = FavoritesViewModel()
    @State private var myRiskViewModel = MyRiskViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(occupationService)
                .environment(favoritesViewModel)
                .environment(myRiskViewModel)
        }
    }
}
