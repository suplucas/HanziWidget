import Foundation
import Testing
@testable import HanziWidget

struct SRSTests {
    @Test
    func newStateDefaults() {
        let state = SRSState()
        #expect(state.isNew)
        #expect(state.ease == 2.5)
        #expect(state.intervalDays == 0)
        #expect(state.repetitions == 0)
    }

    @Test
    func goodFirstReviewSchedulesTomorrow() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let next = SRSState().graded(by: .good, on: day)
        #expect(next.repetitions == 1)
        #expect(next.intervalDays == 1)
        #expect(!next.isNew)
    }

    @Test
    func easyFirstReviewSchedulesAhead() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let next = SRSState().graded(by: .easy, on: day)
        #expect(next.intervalDays >= 1)
        #expect(next.repetitions == 1)
        #expect(next.ease > 2.5)
    }

    @Test
    func againResetsRepetitionsAndKeepsDueToday() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        var state = SRSState().graded(by: .good, on: day)
        state = state.graded(by: .good, on: day)
        let failed = state.graded(by: .again, on: day)
        #expect(failed.repetitions == 0)
        #expect(failed.intervalDays == 0)
        #expect(failed.ease < state.ease)
        #expect(Calendar.current.isDate(failed.dueDate, inSameDayAs: day))
    }

    @Test
    func hardLowersEaseButKeepsProgress() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        var state = SRSState().graded(by: .good, on: day)
        state = state.graded(by: .good, on: day)
        let hard = state.graded(by: .hard, on: day)
        #expect(hard.ease < state.ease)
        #expect(hard.ease >= 1.3)
        #expect(hard.intervalDays >= 1)
    }

    @Test
    func easeNeverBelowFloor() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        var state = SRSState(ease: 1.35)
        for _ in 0..<10 {
            state = state.graded(by: .again, on: day)
        }
        #expect(state.ease >= 1.3)
    }

    @Test
    func practiceQueuePutsDueBeforeNew() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let dueState = SRSState().graded(by: .good, on: yesterday)
        let states = [1: dueState]
        let queue = SRSScheduler.practiceQueue(states: states, allIDs: [1, 2, 3], now: now)
        #expect(queue.first == 1)
        #expect(queue.contains(2))
        #expect(queue.contains(3))
    }

    @Test
    func reviewIDsSkipsUntouchedFavoriteRows() {
        let states = [1: SRSState()]
        let due = SRSScheduler.reviewIDs(states: states, allIDs: [1], now: Date())
        #expect(due.isEmpty)
        let fresh = SRSScheduler.newIDs(states: states, allIDs: [1])
        #expect(fresh == [1])
    }

    @Test
    func knownCountCountsReviewedOnly() {
        let day = Date()
        let states = [
            1: SRSState().graded(by: .good, on: day),
            2: SRSState(),
        ]
        #expect(SRSScheduler.knownCount(states: states) == 1)
    }

    @Test
    func dueCountIncludesFailedSameDay() {
        let now = Date()
        let states = [1: SRSState().graded(by: .again, on: now)]
        #expect(SRSScheduler.dueCount(states: states, now: now) == 1)
    }
}
