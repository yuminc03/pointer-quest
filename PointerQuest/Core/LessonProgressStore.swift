import Foundation

/// 완료한 레슨 id를 `UserDefaults`에 저장하고, 완료 여부 변경을 View에 알리는 관찰 가능한 저장소
@MainActor
final class LessonProgressStore: ObservableObject {
  static let shared = LessonProgressStore()

  @Published private(set) var completedLessonIds: Set<Int>

  private let storageKey = "completedLessonIds"

  private init() {
    let saved = UserDefaults.standard.array(forKey: storageKey) as? [Int] ?? []
    completedLessonIds = Set(saved)
  }

  func isCompleted(_ lessonId: Int) -> Bool {
    completedLessonIds.contains(lessonId)
  }

  /// 레슨 완료를 기록. 이미 완료된 레슨이면 아무 동작도 하지 않는다
  func markCompleted(_ lessonId: Int) {
    guard completedLessonIds.insert(lessonId).inserted else { return }
    UserDefaults.standard.set(Array(completedLessonIds), forKey: storageKey)
  }
}
