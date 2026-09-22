import Foundation
import SwiftData
import Testing
@testable import HanziWidget

@MainActor
struct ReviewRepositoryTests {
    private func makeRepository() throws -> ReviewRepository {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ReviewState.self, configurations: config)
        return ReviewRepository(context: container.mainContext)
    }

    @Test
    func gradeCreatesAndPersistsState() throws {
        let repo = try makeRepository()
        repo.grade(hanziID: 42, .good)
        let state = repo.state(for: 42)
        #expect(state != nil)
        #expect(state?.repetitions == 1)
        #expect(state?.intervalDays == 1)
    }

    @Test
    func gradeAgainIncrementsIncorrect() throws {
        let repo = try makeRepository()
        repo.grade(hanziID: 7, .good)
        repo.grade(hanziID: 7, .again)
        #expect(repo.state(for: 7)?.incorrectCount == 1)
        #expect(repo.state(for: 7)?.repetitions == 0)
    }

    @Test
    func toggleFavoriteFlipsFlag() throws {
        let repo = try makeRepository()
        #expect(repo.toggleFavorite(hanziID: 5) == true)
        #expect(repo.favoriteIDs().contains(5))
        #expect(repo.toggleFavorite(hanziID: 5) == false)
        #expect(!repo.favoriteIDs().contains(5))
    }

    @Test
    func knownAndDueCounts() throws {
        let repo = try makeRepository()
        #expect(repo.knownCount() == 0)
        #expect(repo.dueCount() == 0)
        repo.grade(hanziID: 1, .good)
        #expect(repo.knownCount() == 1)
        #expect(repo.dueCount() == 0)
        repo.grade(hanziID: 2, .again)
        #expect(repo.dueCount() == 1)
    }

    @Test
    func practiceQueueIncludesDueAndNew() throws {
        let repo = try makeRepository()
        repo.grade(hanziID: 1, .again)
        let queue = repo.practiceQueue(allIDs: [1, 2, 3])
        #expect(queue.contains(1))
        #expect(queue.contains(2))
    }

    @Test
    func resetDeletesState() throws {
        let repo = try makeRepository()
        repo.grade(hanziID: 9, .good)
        repo.reset(hanziID: 9)
        #expect(repo.state(for: 9) == nil)
    }
}
