import SwiftUI

@main
struct MIRSimuladorApp: App {
    @StateObject private var repository = QuestionRepository.shared
    @StateObject private var statsStore = StatsStore.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(repository)
                .environmentObject(statsStore)
        }
    }
}
