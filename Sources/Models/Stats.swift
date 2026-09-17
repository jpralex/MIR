import Foundation

struct QuestionAttempt: Codable {
    let questionId: String
    let selectedIndex: Int
    let wasCorrect: Bool
    let date: Date
}

struct UserStats: Codable {
    var attempts: [QuestionAttempt] = []

    func attempts(for specialty: String, questions: [Question]) -> [QuestionAttempt] {
        let ids = Set(questions.filter { $0.specialty == specialty }.map { $0.id })
        return attempts.filter { ids.contains($0.questionId) }
    }

    var totalAnswered: Int { attempts.count }
    var totalCorrect: Int { attempts.filter { $0.wasCorrect }.count }
    var accuracy: Double {
        totalAnswered == 0 ? 0 : Double(totalCorrect) / Double(totalAnswered)
    }

    func accuracy(for specialty: String, questions: [Question]) -> Double? {
        let a = attempts(for: specialty, questions: questions)
        guard !a.isEmpty else { return nil }
        return Double(a.filter { $0.wasCorrect }.count) / Double(a.count)
    }
}
