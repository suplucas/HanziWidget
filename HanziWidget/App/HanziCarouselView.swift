import SwiftData
import SwiftUI

struct HanziCarouselView: View {
    @Environment(\.hanziStore) private var store
    @Environment(\.modelContext) private var modelContext

    @State private var cardIndex: Int? = 0
    @State private var favorites: Set<Int> = []
    @State private var knownCount = 0
    @State private var dueCount = 0

    private var currentCardIndex: Int { cardIndex ?? 0 }

    private var repository: ReviewRepository {
        ReviewRepository(context: modelContext)
    }

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
                                isCurrent: index == currentCardIndex,
                                isFavorite: favorites.contains(item.id),
                                showsActions: true,
                                onGrade: { grade in
                                    repository.grade(hanziID: item.id, grade)
                                    refreshStats()
                                },
                                onToggleFavorite: {
                                    repository.toggleFavorite(hanziID: item.id)
                                    refreshStats()
                                },
                                onSpeak: {
                                    SpeechService.shared.speakHanzi(item)
                                }
                            )
                            .padding(.vertical, 8)
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
        .onAppear(perform: refreshStats)
        .onChange(of: modelContext.hasChanges) { _, hasChanges in
            if hasChanges { refreshStats() }
        }
    }

    private func refreshStats() {
        favorites = repository.favoriteIDs()
        knownCount = repository.knownCount()
        dueCount = repository.dueCount()
    }

    private var header: some View {
        HStack {
            Text("Hanzi")
                .font(.largeTitle.bold())
                .accessibilityIdentifier("carousel_title")
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(currentCardIndex + 1)/\(store.all.count)")
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(.secondary)
                Text("\(knownCount) sabidos · \(dueCount) hoje")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("progress_counter")
            }
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
        .environment(\.hanziStore, HanziStore())
        .modelContainer(for: ReviewState.self, inMemory: true)
}
