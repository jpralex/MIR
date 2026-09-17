import SwiftUI

struct StatsView: View {
    @EnvironmentObject var statsStore: StatsStore
    @EnvironmentObject var repository: QuestionRepository

    var body: some View {
        List {
            Section {
                HStack {
                    StatTile(value: "\(statsStore.stats.totalAnswered)", label: "Respondidas")
                    StatTile(value: "\(statsStore.stats.totalCorrect)", label: "Correctas")
                    StatTile(value: percentageText(statsStore.stats.accuracy), label: "Precisión")
                }
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)
            }

            Section("Por especialidad") {
                ForEach(repository.specialties, id: \.self) { specialty in
                    let questions = repository.questions(specialty: specialty)
                    if let accuracy = statsStore.stats.accuracy(for: specialty, questions: questions) {
                        HStack {
                            Text(specialty)
                            Spacer()
                            Text(percentageText(accuracy))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if statsStore.stats.totalAnswered > 0 {
                Section {
                    Button("Reiniciar estadísticas", role: .destructive) {
                        statsStore.reset()
                    }
                }
            }
        }
        .navigationTitle("Estadísticas")
    }

    private func percentageText(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }
}

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack { StatsView() }
        .environmentObject(QuestionRepository.shared)
        .environmentObject(StatsStore.shared)
}
