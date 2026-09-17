import SwiftUI

struct QuestionReviewView: View {
    let question: Question
    let selectedIndex: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
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
                        AnswerOptionView(index: index, text: text, state: state(for: index)) {}
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal)

                FeedbackPanel(question: question)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
            .padding(.top, 8)
        }
        .navigationTitle("Pregunta \(question.number)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func state(for index: Int) -> AnswerOptionView.State {
        guard !question.annulled, let correct = question.correctIndex else {
            return index == selectedIndex ? .selected : .idle
        }
        if index == correct { return .correct }
        if index == selectedIndex { return .incorrect }
        return .idle
    }
}
