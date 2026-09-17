import SwiftUI
import UIKit

struct QuestionImagesView: View {
    let names: [String]
    @EnvironmentObject var repository: QuestionRepository
    @State private var fullScreenImage: UIImage?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(names, id: \.self) { name in
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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .gesture(MagnificationGesture().onChanged { scale = max(1, $0) })
                .onTapGesture(count: 2) { scale = scale > 1 ? 1 : 2 }
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding()
            }
        }
    }
}
