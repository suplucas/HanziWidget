import SwiftData
import SwiftUI

struct PracticeView: View {
    @Environment(\.hanziStore) private var store
    @Environment(\.modelContext) private var modelContext

    @State private var queue: [HanziItem] = []
    @State private var currentIndex = 0
    @State private var options: [HanziItem] = []
    @State private var selectedID: Int?
    @State private var answered = false
    @State private var correctCount = 0
    @State private var finished = false

    private var repository: ReviewRepository {
        ReviewRepository(context: modelContext)
    }

    private var current: HanziItem? {
        guard queue.indices.contains(currentIndex) else { return nil }
        return queue[currentIndex]
    }

    var body: some View {
        NavigationStack {
            Group {
                if finished {
                    summary
                } else if let current {
                    quizBody(for: current)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Prática")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Recomeçar") {
                        start()
                    }
                    .accessibilityIdentifier("practice_restart")
                }
            }
            .onAppear(perform: start)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Fila vazia",
            systemImage: "checkmark.circle",
            description: Text("Nada para revisar agora. Volte mais tarde ou navegue no carrossel.")
        )
    }

    private var summary: some View {
        VStack(spacing: 16) {
            Image(systemName: "party.popper")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Sessão concluída")
                .font(.title2.bold())
            Text("\(correctCount)/\(queue.count) corretas")
                .font(.title3.monospacedDigit())
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("practice_score")
            Button("Praticar de novo") {
                start()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("practice_again")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func quizBody(for item: HanziItem) -> some View {
        VStack(spacing: 24) {
            Text("Qual o significado?")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(item.character)
                .font(.system(size: 96, weight: .bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityIdentifier("quiz_hanzi")

            Text(item.pinyin)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.blue)
                .opacity(answered ? 1 : 0.4)
                .accessibilityIdentifier("quiz_pinyin")

            VStack(spacing: 10) {
                ForEach(options, id: \.id) { option in
                    Button {
                        answer(option, correct: item)
                    } label: {
                        HStack {
                            Text(option.meaning)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if answered, option.id == item.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else if answered, option.id == selectedID {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.bordered)
                    .disabled(answered)
                    .accessibilityIdentifier("quiz_option_\(option.id)")
                }
            }

            Spacer()

            if answered {
                Button("Continuar") {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("quiz_continue")
            }
        }
        .padding(24)
    }

    private func start() {
        let ids = store.all.map(\.id)
        let q = repository.practiceQueue(allIDs: ids)
        queue = q.compactMap { store.item(id: $0) }
        if queue.isEmpty {
            queue = Array(store.all.shuffled().prefix(min(5, store.all.count)))
        }
        currentIndex = 0
        correctCount = 0
        finished = false
        answered = false
        selectedID = nil
        prepareOptions()
    }

    private func prepareOptions() {
        guard let current else {
            options = []
            return
        }
        var distractors = store.all.filter { $0.id != current.id }.shuffled()
        distractors = Array(distractors.prefix(3))
        options = (distractors + [current]).shuffled()
        selectedID = nil
        answered = false
    }

    private func answer(_ option: HanziItem, correct: HanziItem) {
        guard !answered else { return }
        selectedID = option.id
        answered = true
        let grade: ReviewGrade = option.id == correct.id ? .good : .again
        repository.grade(hanziID: correct.id, grade)
        if option.id == correct.id {
            correctCount += 1
        }
    }

    private func advance() {
        currentIndex += 1
        if queue.indices.contains(currentIndex) {
            prepareOptions()
        } else {
            finished = true
        }
    }
}

#Preview {
    PracticeView()
        .environment(\.hanziStore, HanziStore())
        .modelContainer(for: ReviewState.self, inMemory: true)
}
