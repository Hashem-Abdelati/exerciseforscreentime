import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1 // 0=Setup, 1=Earn
    @StateObject private var bank = TimeBank()

    var body: some View {
        TabView(selection: $selectedTab) {
            SetupViewShortcuts()
                .tabItem { Label("Setup", systemImage: "gear") }
                .tag(0)

            EarnTimeView(bank: bank)
                .tabItem { Label("Earn", systemImage: "figure.strengthtraining.traditional") }
                .tag(1)
        }
        .onOpenURL { url in
            // exercisetime://workout
            if url.host == "workout" {
                selectedTab = 1
            }
        }
    }
}
