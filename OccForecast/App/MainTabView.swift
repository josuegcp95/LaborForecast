import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "square.grid.2x2")
                }

            MyRiskView()
                .tabItem {
                    Label("My Risk", systemImage: "gauge.medium")
                }

            FavoritesView()
                .tabItem {
                    Label("Saved", systemImage: "heart")
                }
        }
        .tint(.occGreen)
    }
}
