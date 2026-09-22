import SwiftUI

struct HanziCardView: View {
    let item: HanziItem
    let isCurrent: Bool

    @State private var stage = 0

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            // TabView horizontal = reveal por swipe; não bloqueia o scroll vertical de fora
            TabView(selection: $stage) {
                stageView(0).tag(0)
                stageView(1).tag(1)
                stageView(2).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity)

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
        .onChange(of: isCurrent) { _, current in
            if current { stage = 0 }
        }
    }

    @ViewBuilder
    private func stageView(_ stageIndex: Int) -> some View {
        VStack(spacing: 16) {
            Text(item.character)
                .font(.system(size: 120, weight: .bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            if stageIndex >= 1 {
                Text(item.pinyin)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.blue)
            }

            if stageIndex >= 2 {
                Text(item.meaning)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

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
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .animation(.snappy(duration: 0.12), value: stage)
    }
}
