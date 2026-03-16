//
//  LaborForecastApp.swift
//  LaborForecast
//
//  Created by Josue Cruz on 3/15/26.
//

import SwiftUI

@main
struct LaborForecastApp: App {
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
