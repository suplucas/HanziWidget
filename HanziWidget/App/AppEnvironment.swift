import SwiftUI

private struct HanziStoreKey: EnvironmentKey {
    nonisolated static let defaultValue: HanziStore = .shared
}

extension EnvironmentValues {
    var hanziStore: HanziStore {
        get { self[HanziStoreKey.self] }
        set { self[HanziStoreKey.self] = newValue }
    }
}
