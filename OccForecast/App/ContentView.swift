import SwiftUI

struct ContentView: View {
    @Environment(OccupationService.self) var occupationService
    @Environment(FavoritesViewModel.self) var favoritesViewModel
    @Environment(MyRiskViewModel.self) var myRiskViewModel
    @State private var showLaunch = true

    var body: some View {
        Group {
            if showLaunch {
                LaunchView {
                    showLaunch = false
                }
            } else {
                MainTabView()
            }
        }
        .onAppear {
            favoritesViewModel.load(from: occupationService)
            myRiskViewModel.load(from: occupationService)
        }
        .onChange(of: occupationService.isLoaded) { _, loaded in
            if loaded {
                favoritesViewModel.load(from: occupationService)
                myRiskViewModel.load(from: occupationService)
            }
        }
    }
}
