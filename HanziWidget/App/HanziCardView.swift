import SwiftUI

struct HanziCardView: View {
    let item: HanziItem
    let isCurrent: Bool

    var isFavorite: Bool = false
    var showsActions: Bool = false
    var onGrade: ((ReviewGrade) -> Void)?
    var onToggleFavorite: (() -> Void)?
    var onSpeak: (() -> Void)?

    @State private var stage = 0
    @State private var graded = false

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            TabView(selection: $stage) {
                stageView(0).tag(0)
                stageView(1).tag(1)
                stageView(2).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            if stage >= 2, showsActions, !graded {
                actionRow
                    .padding(.bottom, 16)
            } else {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i <= stage ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }

            if graded {
                Text("Registrado")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.green)
                    .padding(.bottom, 20)
                    .accessibilityIdentifier("grade_recorded")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .onChange(of: isCurrent) { _, current in
            if current {
                stage = 0
                graded = false
            }
        }
        .accessibilityIdentifier("hanzi_card_\(item.id)")
    }

    private var actionRow: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    onSpeak?()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
                .accessibilityIdentifier("speak_button")

                Button {
                    onToggleFavorite?()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(isFavorite ? .yellow : .primary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityIdentifier("favorite_button")
            }

            HStack(spacing: 8) {
                ForEach(ReviewGrade.allCases) { grade in
                    Button {
                        graded = true
                        onGrade?(grade)
                    } label: {
                        Text(grade.label)
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(tint(for: grade))
                    .accessibilityIdentifier("grade_\(grade.label)")
                }
            }
        }
    }

    private func tint(for grade: ReviewGrade) -> Color {
        switch grade {
        case .again: .red
        case .hard: .orange
        case .good: .blue
        case .easy: .green
        }
    }

    @ViewBuilder
    private func stageView(_ stageIndex: Int) -> some View {
        VStack(spacing: 16) {
            Text(item.character)
                .font(.system(size: 120, weight: .bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityIdentifier("hanzi_character")

            if stageIndex >= 1 {
                Text(item.pinyin)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.blue)
                    .accessibilityIdentifier("hanzi_pinyin")
            }

            if stageIndex >= 2 {
                Text(item.meaning)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .accessibilityIdentifier("hanzi_meaning")

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
