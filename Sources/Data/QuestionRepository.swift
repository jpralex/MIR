import Foundation

@MainActor
final class QuestionRepository: ObservableObject {
    @Published private(set) var questions: [Question] = []
    @Published private(set) var exams: [ExamInfo] = []

    static let shared = QuestionRepository()

    private init() {
        load()
    }

    private func load() {
        exams = [ExamInfo(id: "mir2025", title: "MIR 2025", year: 2025, source: "Ministerio de Sanidad")]

        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json", subdirectory: "Exams/mir2025") else {
            assertionFailure("No se encontró questions.json en el bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            questions = try JSONDecoder().decode([Question].self, from: data)
        } catch {
            assertionFailure("Error al decodificar questions.json: \(error)")
        }
    }

    var specialties: [String] {
        SpecialtyCatalog.sorted(Array(Set(questions.map { $0.specialty })))
    }

    func questions(specialty: String) -> [Question] {
        questions.filter { $0.specialty == specialty }.sorted { $0.number < $1.number }
    }

    func questions(examId: String) -> [Question] {
        questions.filter { $0.examId == examId }.sorted { $0.number < $1.number }
    }

    func count(specialty: String) -> Int {
        questions.filter { $0.specialty == specialty }.count
    }

    func imageURL(named name: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Exams/mir2025/images")
    }
}
