import SwiftUI
import UIKit

struct QuestionImagesView: View {
    let names: [String]
    @EnvironmentObject var repository: QuestionRepository
    @State private var fullScreenImage: UIImage?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(names.enumerated()), id: \.offset) { position, name in
                    if let image = loadImage(name) {
                        Button {
                            fullScreenImage = image
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(imageAccessibilityLabel(position: position))
                        .accessibilityHint("Activa dos veces para ver la imagen ampliada")
                    }
                }
            }
            .padding(.horizontal)
        }
        .fullScreenCover(item: $fullScreenImage.asIdentifiableBinding) { wrapper in
            ZoomableImageView(image: wrapper.image)
        }
    }

    private func loadImage(_ name: String) -> UIImage? {
        guard let url = repository.imageURL(named: name) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    private func imageAccessibilityLabel(position: Int) -> String {
        names.count > 1
            ? "Imagen clínica \(position + 1) de \(names.count) asociada a esta pregunta"
            : "Imagen clínica asociada a esta pregunta"
    }
}

private struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

private extension Binding where Value == UIImage? {
    var asIdentifiableBinding: Binding<IdentifiableImage?> {
        Binding<IdentifiableImage?>(
            get: { wrappedValue.map(IdentifiableImage.init) },
            set: { wrappedValue = $0?.image }
        )
    }
}

private struct ZoomableImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 5

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .accessibilityLabel("Imagen clínica ampliada")
                .gesture(magnifyGesture)
                .simultaneousGesture(dragGesture, including: scale > 1 ? .all : .none)
                .onTapGesture(count: 2, perform: toggleZoom)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding()
            }
            .accessibilityLabel("Cerrar")
        }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(minScale, lastScale * value), maxScale)
            }
            .onEnded { _ in
                lastScale = scale
                if scale == minScale { resetOffset() }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in lastOffset = offset }
    }

    private func toggleZoom() {
        if scale > minScale {
            scale = minScale
            lastScale = minScale
            resetOffset()
        } else {
            scale = 2
            lastScale = 2
        }
    }

    private func resetOffset() {
        offset = .zero
        lastOffset = .zero
    }
}
