import SwiftUI

struct ExamListView: View {
    @EnvironmentObject var repository: QuestionRepository

    var body: some View {
        List(repository.exams) { exam in
            let questions = repository.questions(examId: exam.id)
            NavigationLink {
                QuizView(session: QuizSession(
                    title: exam.title,
                    questions: questions,
                    mode: .exam
                ))
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exam.title).font(.headline)
                    Text("\(questions.count) preguntas · \(exam.source)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Exámenes")
    }
}

#Preview {
    NavigationStack { ExamListView() }
        .environmentObject(QuestionRepository.shared)
        .environmentObject(StatsStore.shared)
}
