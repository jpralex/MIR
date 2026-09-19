import SwiftUI

struct ResultsView: View {
    @ObservedObject var session: QuizSession
    @EnvironmentObject var router: AppRouter

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text("\(session.correctCount) / \(session.scoreableQuestions.count)")
                        .font(.system(.largeTitle, design: .rounded).bold())
                    Text("respuestas correctas")
                        .foregroundStyle(.secondary)
                    if session.mode == .exam {
                        Text(scoreLine)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Section("Repaso de preguntas") {
                ForEach(session.questions) { question in
                    NavigationLink {
                        QuestionReviewView(question: question, selectedIndex: session.selectedByQuestion[question.id])
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            statusIcon(for: question)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Pregunta \(question.number)")
                                Text(question.specialty)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Resultados")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Inicio") {
                    router.returnToHome()
                }
            }
        }
    }

    private var scoreLine: String {
        let correct = session.correctCount
        let incorrect = session.incorrectCount
        let net = Double(correct) - Double(incorrect) / 3.0
        return String(format: "Aciertos: %d · Errores: %d · Nota (3 fallos resta 1 acierto): %.2f", correct, incorrect, net)
    }

    @ViewBuilder
    private func statusIcon(for question: Question) -> some View {
        if question.annulled {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
        } else if let selected = session.selectedByQuestion[question.id] {
            if selected == question.correctIndex {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            } else {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
            }
        } else {
            Image(systemName: "circle.dashed").foregroundStyle(.secondary)
        }
    }
}
