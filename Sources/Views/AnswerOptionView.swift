import SwiftUI

struct AnswerOptionView: View {
    enum State {
        case idle, selected, correct, incorrect
    }

    let index: Int
    let text: String
    let state: State
    let action: () -> Void

    private static let letters = ["A", "B", "C", "D", "E"]

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Text(Self.letters[safe: index] ?? "?")
                    .font(.subheadline.bold())
                    .frame(width: 26, height: 26)
                    .background(badgeColor.opacity(0.15))
                    .foregroundStyle(badgeColor)
                    .clipShape(Circle())
                Text(text)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if state == .incorrect {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding(12)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: state == .selected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var badgeColor: Color {
        switch state {
        case .correct: return .green
        case .incorrect: return .red
        case .selected: return .accentColor
        case .idle: return .secondary
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .correct: return Color.green.opacity(0.12)
        case .incorrect: return Color.red.opacity(0.12)
        case .selected: return Color.accentColor.opacity(0.10)
        case .idle: return Color(.secondarySystemBackground)
        }
    }

    private var borderColor: Color {
        switch state {
        case .correct: return .green
        case .incorrect: return .red
        case .selected: return .accentColor
        case .idle: return .clear
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
