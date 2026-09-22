import Foundation
import SwiftData

@Model
final class ReviewState {
    @Attribute(.unique) var hanziID: Int
    var ease: Double
    var intervalDays: Int
    var repetitions: Int
    var dueDate: Date
    var lastReviewedAt: Date?
    var isFavorite: Bool
    var incorrectCount: Int
    var createdAt: Date

    init(
        hanziID: Int,
        ease: Double = 2.5,
        intervalDays: Int = 0,
        repetitions: Int = 0,
        dueDate: Date = .distantPast,
        lastReviewedAt: Date? = nil,
        isFavorite: Bool = false,
        incorrectCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.hanziID = hanziID
        self.ease = ease
        self.intervalDays = intervalDays
        self.repetitions = repetitions
        self.dueDate = dueDate
        self.lastReviewedAt = lastReviewedAt
        self.isFavorite = isFavorite
        self.incorrectCount = incorrectCount
        self.createdAt = createdAt
    }

    var srsState: SRSState {
        SRSState(
            ease: ease,
            intervalDays: intervalDays,
            repetitions: repetitions,
            dueDate: dueDate
        )
    }

    func apply(_ srs: SRSState, on date: Date, wasIncorrect: Bool = false) {
        ease = srs.ease
        intervalDays = srs.intervalDays
        repetitions = srs.repetitions
        dueDate = srs.dueDate
        lastReviewedAt = date
        if wasIncorrect {
            incorrectCount += 1
        }
    }
}
