import Foundation

@MainActor
final class StatsStore: ObservableObject {
    @Published private(set) var stats = UserStats()

    static let shared = StatsStore()

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("mir_stats.json")
    }()

    private init() {
        load()
    }

    func record(questionId: String, selectedIndex: Int, wasCorrect: Bool) {
        let attempt = QuestionAttempt(questionId: questionId, selectedIndex: selectedIndex, wasCorrect: wasCorrect, date: Date())
        stats.attempts.append(attempt)
        save()
    }

    func reset() {
        stats = UserStats()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            stats = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
