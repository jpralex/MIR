import SwiftUI

struct HomeView: View {
    @EnvironmentObject var repository: QuestionRepository
    @EnvironmentObject var statsStore: StatsStore
    @StateObject private var router = AppRouter()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        SpecialtyListView()
                    } label: {
                        HomeRow(icon: "stethoscope", title: "Por especialidad",
                                subtitle: "Practica preguntas agrupadas por especialidad médica")
                    }
                    NavigationLink {
                        ExamListView()
                    } label: {
                        HomeRow(icon: "doc.text.magnifyingglass", title: "Por examen",
                                subtitle: "Simula un examen MIR completo, tal y como se convocó")
                    }
                    NavigationLink {
                        StatsView()
                    } label: {
                        HomeRow(icon: "chart.bar.xaxis", title: "Mis estadísticas",
                                subtitle: "\(statsStore.stats.totalAnswered) preguntas respondidas")
                    }
                } header: {
                    Text("Simulador MIR")
                } footer: {
                    Text("Preguntas oficiales del examen MIR 2025 (Ministerio de Sanidad), con sus respuestas correctas aprobadas por la Comisión Calificadora. Las explicaciones se irán añadiendo progresivamente.")
                }
            }
            .navigationTitle("MIR Simulador")
        }
        .id(router.resetToken)
        .environmentObject(router)
    }
}

private struct HomeRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
        .environmentObject(QuestionRepository.shared)
        .environmentObject(StatsStore.shared)
}
