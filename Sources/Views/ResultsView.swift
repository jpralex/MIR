import SwiftUI

struct ResultsView: View {
    @ObservedObject var session: QuizSession

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text("\(session.correctCount) / \(session.scoreableQuestions.count)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
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
                        HStack {
                            statusIcon(for: question)
                            Text("Pregunta \(question.number)")
                            Spacer()
                            Text(question.specialty)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .navigationTitle("Resultados")
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
