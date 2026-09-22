import SwiftUI

struct HanziCarouselView: View {
    private let store = HanziStore.shared

    @State private var cardIndex: Int? = 0

    private var currentCardIndex: Int { cardIndex ?? 0 }

    var body: some View {
        VStack(spacing: 0) {
            header

            GeometryReader { geo in
                let cardWidth = geo.size.width * 0.85

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(store.all.enumerated()), id: \.element.id) { index, item in
                            HanziCardView(
                                item: item,
                                isCurrent: index == currentCardIndex
                            )
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .containerRelativeFrame(.vertical)
                            .frame(width: cardWidth)
                            .id(index)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollTargetBehavior(.paging)
                .scrollTargetLayout()
                .scrollPosition(id: $cardIndex, anchor: .center)
            }
            .frame(maxHeight: .infinity)

            dots
        }
        .background(Color(.systemBackground))
    }

    private var header: some View {
        HStack {
            Text("Hanzi")
                .font(.largeTitle.bold())
            Spacer()
            Text("\(currentCardIndex + 1)/\(store.all.count)")
                .font(.title3.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var dots: some View {
        if store.all.count <= 12 {
            HStack(spacing: 8) {
                ForEach(0..<store.all.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentCardIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: i == currentCardIndex ? 24 : 8, height: 8)
                }
            }
            .padding(.bottom, 24)
            .animation(.snappy(duration: 0.2), value: currentCardIndex)
        } else {
            Capsule()
                .fill(Color.accentColor)
                .frame(width: 40, height: 6)
                .padding(.bottom, 24)
        }
    }
}

#Preview {
    HanziCarouselView()
}
