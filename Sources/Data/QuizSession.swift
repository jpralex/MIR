import Foundation

enum QuizMode {
    case practice   // feedback inmediato tras cada respuesta
    case exam       // se responde todo y se corrige al final, como en el examen real
}

@MainActor
final class QuizSession: ObservableObject {
    let title: String
    let questions: [Question]
    let mode: QuizMode

    @Published var currentIndex: Int = 0
    @Published var selectedByQuestion: [String: Int] = [:]
    @Published var isFinished: Bool = false
    private(set) var hasRecordedResults = false

    init(title: String, questions: [Question], mode: QuizMode = .practice) {
        self.title = title
        self.questions = questions
        self.mode = mode
    }

    var current: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count)
    }

    func select(_ index: Int, for question: Question) {
        guard selectedByQuestion[question.id] == nil || mode == .exam else { return }
        selectedByQuestion[question.id] = index
    }

    func goNext() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }

    func goPrevious() {
        if currentIndex > 0 { currentIndex -= 1 }
    }

    /// Marca esta sesión como ya registrada en las estadísticas, para que
    /// volver a "Finalizar" tras revisar el examen no cuente las respuestas
    /// dos veces. Devuelve `true` la primera vez (hay que registrar) y
    /// `false` en cualquier llamada posterior.
    func markResultsRecordedIfNeeded() -> Bool {
        guard !hasRecordedResults else { return false }
        hasRecordedResults = true
        return true
    }

    func isCorrect(_ question: Question) -> Bool? {
        guard let selected = selectedByQuestion[question.id], let correct = question.correctIndex else { return nil }
        return selected == correct
    }

    var answeredCount: Int { selectedByQuestion.count }

    var scoreableQuestions: [Question] {
        questions.filter { !$0.annulled }
    }

    var correctCount: Int {
        scoreableQuestions.filter { isCorrect($0) == true }.count
    }

    var incorrectCount: Int {
        scoreableQuestions.filter { q in
            guard let sel = selectedByQuestion[q.id] else { return false }
            return sel != q.correctIndex
        }.count
    }
}
