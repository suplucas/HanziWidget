import SwiftUI

struct HanziCarouselView: View {
    private let store = HanziStore.shared

    @State private var cardIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            header

            GeometryReader { geo in
                let cardWidth = geo.size.width * 0.85
                let spacing = (geo.size.width - cardWidth) / 2

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            ForEach(Array(store.all.enumerated()), id: \.element.id) { index, item in
                                HanziCardView(
                                    item: item,
                                    isCurrent: index == cardIndex,
                                    onSwipeLeftAtEnd: { moveCard(+1, proxy: proxy) },
                                    onSwipeRightAtStart: { moveCard(-1, proxy: proxy) }
                                )
                                .frame(width: cardWidth)
                                .id(index)
                            }
                        }
                        .padding(.horizontal, spacing)
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollTargetLayout()
                    .onAppear {
                        proxy.scrollTo(cardIndex, anchor: .center)
                    }
                }
            }
            .frame(maxHeight: .infinity)

            dots
        }
        .background(Color(.systemBackground))
    }

    private func moveCard(_ delta: Int, proxy: ScrollViewProxy) {
        let newIndex = cardIndex + delta
        guard store.all.indices.contains(newIndex) else { return }
        withAnimation(.snappy(duration: 0.3)) {
            cardIndex = newIndex
            proxy.scrollTo(newIndex, anchor: .center)
        }
    }

    private var header: some View {
        HStack {
            Text("Hanzi")
                .font(.largeTitle.bold())
            Spacer()
            Text("\(cardIndex + 1)/\(store.all.count)")
                .font(.title3.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var dots: some View {
        // Evita centenas de dots com datasets grandes
        if store.all.count <= 12 {
            HStack(spacing: 8) {
                ForEach(0..<store.all.count, id: \.self) { i in
                    Capsule()
                        .fill(i == cardIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: i == cardIndex ? 24 : 8, height: 8)
                }
            }
            .padding(.bottom, 24)
            .animation(.snappy(duration: 0.25), value: cardIndex)
        } else {
            Capsule()
                .fill(Color.accentColor)
                .frame(width: 40, height: 6)
                .padding(.bottom, 24)
        }
    }
}

private struct HanziCardView: View {
    let item: HanziItem
    let isCurrent: Bool
    let onSwipeLeftAtEnd: () -> Void
    let onSwipeRightAtStart: () -> Void

    @State private var stage = 0
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 16) {
                Text(item.character)
                    .font(.system(size: 120, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                if stage >= 1 {
                    Text(item.pinyin)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.blue)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if stage >= 2 {
                    Text(item.meaning)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    if let exHanzi = item.exemploHanzi {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Text(exHanzi)
                                    .font(.body.weight(.medium))
                                if let exPinyin = item.exemploPinyin {
                                    Text(exPinyin)
                                        .font(.footnote)
                                        .foregroundStyle(.blue.opacity(0.8))
                                }
                            }
                            if let exTraducao = item.exemploTraducao {
                                Text(exTraducao)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 4)
                        .padding(.horizontal, 8)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 16)
            .offset(x: dragOffset)
            .animation(.snappy(duration: 0.3), value: stage)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(i <= stage ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .gesture(cardDrag)
        .onChange(of: isCurrent) { _, current in
            if current {
                stage = 0
                dragOffset = 0
            }
        }
    }

    private var cardDrag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                dragOffset = value.translation.width * 0.3
            }
            .onEnded { value in
                let horizontal = value.translation.width
                dragOffset = 0

                guard abs(horizontal) > 40 else { return }

                if horizontal < 0 {
                    if stage < 2 {
                        stage += 1
                    } else {
                        onSwipeLeftAtEnd()
                    }
                } else {
                    if stage > 0 {
                        stage -= 1
                    } else {
                        onSwipeRightAtStart()
                    }
                }
            }
    }
}

#Preview {
    HanziCarouselView()
}
