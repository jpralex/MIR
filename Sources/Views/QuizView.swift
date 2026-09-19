import SwiftUI

struct QuizView: View {
    @StateObject var session: QuizSession
    @EnvironmentObject var statsStore: StatsStore
    @EnvironmentObject var repository: QuestionRepository
    @State private var showsUnansweredWarning = false

    var body: some View {
        Group {
            if let question = session.current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        if question.annulled {
                            Label("Pregunta anulada por la Comisión Calificadora", systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                                .padding(.horizontal)
                        }

                        if !question.images.isEmpty {
                            QuestionImagesView(names: question.images)
                        }

                        Text(question.statement)
                            .font(.body)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            ForEach(Array(question.options.enumerated()), id: \.offset) { index, text in
                                AnswerOptionView(
                                    index: index,
                                    text: text,
                                    state: optionState(index: index, question: question)
                                ) {
                                    select(index: index, question: question)
                                }
                            }
                        }
                        .padding(.horizontal)

                        if showsFeedback(for: question) {
                            FeedbackPanel(question: question)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .safeAreaInset(edge: .bottom) {
                    navigationButtons
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(.bar)
                }
            } else {
                ContentUnavailableFallback()
            }
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $session.isFinished) {
            ResultsView(session: session)
        }
        .confirmationDialog(
            "Quedan \(unansweredCount) preguntas sin responder",
            isPresented: $showsUnansweredWarning,
            titleVisibility: .visible
        ) {
            Button("Finalizar de todas formas", role: .destructive) {
                finishExam()
            }
            Button("Seguir respondiendo", role: .cancel) {}
        } message: {
            Text("Si finalizas ahora, esas preguntas se contarán como no respondidas y no podrás volver a cambiarlas.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pregunta \(session.currentIndex + 1) de \(session.questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
            ProgressView(value: Double(session.currentIndex), total: Double(max(session.questions.count, 1)))
        }
        .padding(.horizontal)
    }

    private var navigationButtons: some View {
        HStack {
            if session.mode == .exam && session.currentIndex > 0 {
                Button("Anterior") { session.goPrevious() }
                    .buttonStyle(.bordered)
            }
            Spacer()
            if canAdvance {
                Button(isLastQuestion ? "Finalizar" : "Siguiente") {
                    advance()
                } .buttonStyle(.borderedProminent)
            }
        }
    }

    private var isLastQuestion: Bool {
        session.currentIndex == session.questions.count - 1
    }

    private var canAdvance: Bool {
        guard let question = session.current else { return false }
        if session.mode == .exam || question.annulled { return true }
        return session.selectedByQuestion[question.id] != nil
    }

    private var unansweredCount: Int {
        session.questions.count - session.answeredCount
    }

    private func advance() {
        if isLastQuestion {
            if session.mode == .exam && unansweredCount > 0 {
                showsUnansweredWarning = true
            } else {
                finishExam()
            }
        } else {
            session.goNext()
        }
    }

    private func finishExam() {
        recordExamResultsIfNeeded()
        session.isFinished = true
    }

    private func recordExamResultsIfNeeded() {
        guard session.mode == .exam, session.markResultsRecordedIfNeeded() else { return }
        for question in session.scoreableQuestions {
            guard let selected = session.selectedByQuestion[question.id] else { continue }
            statsStore.record(questionId: question.id, selectedIndex: selected, wasCorrect: selected == question.correctIndex)
        }
    }

    private func select(index: Int, question: Question) {
        let alreadyAnswered = session.selectedByQuestion[question.id] != nil
        session.select(index, for: question)
        if session.mode == .practice, !alreadyAnswered, !question.annulled, let correct = question.correctIndex {
            statsStore.record(questionId: question.id, selectedIndex: index, wasCorrect: index == correct)
        }
    }

    private func showsFeedback(for question: Question) -> Bool {
        session.mode == .practice && session.selectedByQuestion[question.id] != nil
    }

    private func optionState(index: Int, question: Question) -> AnswerOptionView.State {
        guard let selected = session.selectedByQuestion[question.id] else {
            return .idle
        }
        if session.mode == .exam {
            return index == selected ? .selected : .idle
        }
        // practice mode: show correctness
        guard let correct = question.correctIndex, !question.annulled else {
            return index == selected ? .selected : .idle
        }
        if index == correct { return .correct }
        if index == selected { return .incorrect }
        return .idle
    }
}

private struct ContentUnavailableFallback: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No hay preguntas disponibles").font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        QuizView(session: QuizSession(title: "Vista previa", questions: Array(QuestionRepository.shared.questions.prefix(3))))
    }
    .environmentObject(QuestionRepository.shared)
    .environmentObject(StatsStore.shared)
    .environmentObject(AppRouter())
}
