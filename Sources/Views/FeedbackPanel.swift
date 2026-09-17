import SwiftUI

struct FeedbackPanel: View {
    let question: Question

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Explicación", systemImage: "lightbulb")
                .font(.subheadline.bold())
            if let explanation = question.explanation, !explanation.isEmpty {
                Text(explanation)
                    .font(.subheadline)
            } else {
                Text("Todavía no hay una explicación redactada para esta pregunta. Se irán añadiendo progresivamente a medida que se incorpore más material de estudio.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
