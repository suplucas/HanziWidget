import SwiftUI

struct HanziCardView: View {
    let item: HanziItem
    let isCurrent: Bool

    @State private var stage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isHorizontalDrag = false

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
            .animation(.snappy(duration: 0.12), value: stage)
            .animation(.snappy(duration: 0.12), value: dragOffset)

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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .simultaneousGesture(cardDrag)
        .onChange(of: isCurrent) { _, current in
            if current {
                stage = 0
                dragOffset = 0
                isHorizontalDrag = false
            }
        }
    }

    private var cardDrag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let dx = value.translation.width
                let dy = value.translation.height

                if !isHorizontalDrag {
                    guard abs(dx) > 8, abs(dx) > abs(dy) else {
                        dragOffset = 0
                        return
                    }
                    isHorizontalDrag = true
                }

                guard isHorizontalDrag else { return }
                dragOffset = dx * 0.3
            }
            .onEnded { value in
                defer {
                    dragOffset = 0
                    isHorizontalDrag = false
                }

                guard isHorizontalDrag else { return }

                let dx = value.translation.width
                guard abs(dx) > 36 else { return }

                if dx < 0 {
                    if stage < 2 { stage += 1 }
                } else {
                    if stage > 0 { stage -= 1 }
                }
            }
    }
}
