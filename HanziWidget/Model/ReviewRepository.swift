import Foundation
import SwiftData

@MainActor
struct ReviewRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func state(for hanziID: Int) -> ReviewState? {
        let descriptor = FetchDescriptor<ReviewState>(
            predicate: #Predicate { $0.hanziID == hanziID }
        )
        return try? context.fetch(descriptor).first
    }

    func statesByHanziID() -> [Int: ReviewState] {
        guard let all = try? context.fetch(FetchDescriptor<ReviewState>()) else { return [:] }
        return Dictionary(uniqueKeysWithValues: all.map { ($0.hanziID, $0) })
    }

    func srsStates() -> [Int: SRSState] {
        statesByHanziID().mapValues(\.srsState)
    }

    func ensure(hanziID: Int) -> ReviewState {
        if let existing = state(for: hanziID) {
            return existing
        }
        let created = ReviewState(hanziID: hanziID)
        context.insert(created)
        return created
    }

    @discardableResult
    func grade(hanziID: Int, _ grade: ReviewGrade, on date: Date = Date()) -> ReviewState {
        let model = ensure(hanziID: hanziID)
        let next = model.srsState.graded(by: grade, on: date)
        model.apply(next, on: date, wasIncorrect: grade == .again)
        try? context.save()
        return model
    }

    @discardableResult
    func toggleFavorite(hanziID: Int) -> Bool {
        let model = ensure(hanziID: hanziID)
        model.isFavorite.toggle()
        try? context.save()
        return model.isFavorite
    }

    func favoriteIDs() -> Set<Int> {
        guard let all = try? context.fetch(FetchDescriptor<ReviewState>()) else { return [] }
        return Set(all.filter(\.isFavorite).map(\.hanziID))
    }

    func practiceQueue(allIDs: [Int], now: Date = Date()) -> [Int] {
        SRSScheduler.practiceQueue(states: srsStates(), allIDs: allIDs, now: now)
    }

    func dueCount(now: Date = Date()) -> Int {
        SRSScheduler.dueCount(states: srsStates(), now: now)
    }

    func knownCount() -> Int {
        SRSScheduler.knownCount(states: srsStates())
    }

    func reset(hanziID: Int) {
        guard let model = state(for: hanziID) else { return }
        context.delete(model)
        try? context.save()
    }
}
