import Foundation

enum ReviewGrade: Int, CaseIterable, Sendable, Identifiable {
    case again
    case hard
    case good
    case easy

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .again: "De novo"
        case .hard: "Difícil"
        case .good: "Sei"
        case .easy: "Fácil"
        }
    }
}

struct SRSState: Equatable, Sendable {
    var ease: Double
    var intervalDays: Int
    var repetitions: Int
    var dueDate: Date

    init(
        ease: Double = 2.5,
        intervalDays: Int = 0,
        repetitions: Int = 0,
        dueDate: Date = .distantPast
    ) {
        self.ease = ease
        self.intervalDays = intervalDays
        self.repetitions = repetitions
        self.dueDate = dueDate
    }

    var isNew: Bool { repetitions == 0 && intervalDays == 0 }
    var isDue: Bool { dueDate <= Date() }

    func graded(by grade: ReviewGrade, on date: Date) -> SRSState {
        var next = self
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)

        switch grade {
        case .again:
            next.repetitions = 0
            next.intervalDays = 0
            next.ease = max(1.3, ease - 0.2)
            next.dueDate = day
        case .hard:
            next.repetitions = max(repetitions, 1)
            next.ease = max(1.3, ease - 0.15)
            next.intervalDays = max(1, intervalDays == 0 ? 1 : Int((Double(intervalDays) * 1.2).rounded()))
            next.dueDate = cal.date(byAdding: .day, value: next.intervalDays, to: day) ?? day
        case .good:
            next.repetitions = repetitions + 1
            next.intervalDays = nextInterval(after: repetitions, base: intervalDays, ease: ease, factor: 1.0)
            next.dueDate = cal.date(byAdding: .day, value: next.intervalDays, to: day) ?? day
        case .easy:
            next.repetitions = repetitions + 1
            next.ease = ease + 0.15
            next.intervalDays = nextInterval(after: repetitions, base: intervalDays, ease: ease, factor: 1.3)
            next.dueDate = cal.date(byAdding: .day, value: next.intervalDays, to: day) ?? day
        }

        return next
    }

    private func nextInterval(after reps: Int, base: Int, ease: Double, factor: Double) -> Int {
        switch reps {
        case 0:
            return max(1, Int((1 * factor).rounded()))
        case 1:
            return max(2, Int((3 * factor).rounded()))
        default:
            let scaled = Double(max(base, 1)) * ease * factor
            return max(1, Int(scaled.rounded()))
        }
    }
}

enum SRSScheduler {
    static func reviewIDs(
        states: [Int: SRSState],
        allIDs: [Int],
        now: Date = Date(),
        limit: Int = 20
    ) -> [Int] {
        let startOfDay = Calendar.current.startOfDay(for: now)
        let due = allIDs.filter { id in
            guard let state = states[id] else { return false }
            if state.dueDate == .distantPast { return false }
            if state.intervalDays == 0, state.repetitions > 0 { return state.dueDate <= now }
            return state.dueDate <= startOfDay
        }
        return Array(due.prefix(limit))
    }

    static func newIDs(
        states: [Int: SRSState],
        allIDs: [Int],
        limit: Int = 10
    ) -> [Int] {
        allIDs
            .filter { id in
                guard let state = states[id] else { return true }
                return state.repetitions == 0 && state.intervalDays == 0 && state.dueDate == .distantPast
            }
            .prefix(limit)
            .map { $0 }
    }

    static func practiceQueue(
        states: [Int: SRSState],
        allIDs: [Int],
        now: Date = Date()
    ) -> [Int] {
        let due = reviewIDs(states: states, allIDs: allIDs, now: now)
        let fresh = newIDs(states: states, allIDs: allIDs)
        return due + fresh
    }

    static func knownCount(states: [Int: SRSState]) -> Int {
        states.values.filter { $0.repetitions > 0 }.count
    }

    static func dueCount(states: [Int: SRSState], now: Date = Date()) -> Int {
        let startOfDay = Calendar.current.startOfDay(for: now)
        return states.values.filter { state in
            if state.dueDate == .distantPast { return false }
            if state.intervalDays == 0, state.repetitions > 0 { return state.dueDate <= now }
            return state.dueDate <= startOfDay
        }.count
    }
}
