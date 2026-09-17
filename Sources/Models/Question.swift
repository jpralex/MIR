import Foundation

struct Question: Codable, Identifiable, Hashable {
    let id: String
    let number: Int
    let examId: String
    let specialty: String
    let statement: String
    let options: [String]
    let correctIndex: Int?
    let annulled: Bool
    let images: [String]
    var explanation: String?

    var hasExplanation: Bool { (explanation?.isEmpty == false) }
}

struct ExamInfo: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let year: Int
    let source: String
}
