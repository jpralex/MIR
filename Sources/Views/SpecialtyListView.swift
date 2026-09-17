import SwiftUI

struct SpecialtyListView: View {
    @EnvironmentObject var repository: QuestionRepository

    var body: some View {
        List(repository.specialties, id: \.self) { specialty in
            let count = repository.count(specialty: specialty)
            NavigationLink {
                QuizView(session: QuizSession(
                    title: specialty,
                    questions: repository.questions(specialty: specialty).shuffled()
                ))
            } label: {
                HStack {
                    Text(specialty)
                    Spacer()
                    Text("\(count)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
            .disabled(count == 0)
        }
        .navigationTitle("Especialidades")
    }
}

#Preview {
    NavigationStack { SpecialtyListView() }
        .environmentObject(QuestionRepository.shared)
        .environmentObject(StatsStore.shared)
}
