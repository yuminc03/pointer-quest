import Foundation

/// 레슨별 진행 상태(완료 여부, 개념 카드 열람 여부)를 `UserDefaults`에 저장하고, 변경을 View에 알리는 관찰 가능한 저장소
@MainActor
final class LessonProgressStore: ObservableObject {
  static let shared = LessonProgressStore()

  @Published private(set) var completedLessonIds: Set<Int>
  /// 개념 카드를 이미 본 레슨 id
  /// 레슨에 처음 들어갈 때만 카드를 자동으로 띄우기 위한 기록이며, 재진입 시에는 툴바의 `(i)`로만 다시 연다
  @Published private(set) var seenConceptCardLessonIds: Set<Int>

  private let storageKey = "completedLessonIds"
  private let conceptCardStorageKey = "seenConceptCardLessonIds"

  private init() {
    let saved = UserDefaults.standard.array(forKey: storageKey) as? [Int] ?? []
    completedLessonIds = Set(saved)

    let savedConceptCards = UserDefaults.standard.array(forKey: conceptCardStorageKey) as? [Int] ?? []
    seenConceptCardLessonIds = Set(savedConceptCards)
  }

  func isCompleted(_ lessonId: Int) -> Bool {
    completedLessonIds.contains(lessonId)
  }

  /// 레슨 완료를 기록. 이미 완료된 레슨이면 아무 동작도 하지 않는다
  func markCompleted(_ lessonId: Int) {
    guard completedLessonIds.insert(lessonId).inserted else { return }
    UserDefaults.standard.set(Array(completedLessonIds), forKey: storageKey)
  }

  func hasSeenConceptCard(_ lessonId: Int) -> Bool {
    seenConceptCardLessonIds.contains(lessonId)
  }

  /// 개념 카드 열람을 기록. 이미 본 레슨이면 아무 동작도 하지 않는다
  func markConceptCardSeen(_ lessonId: Int) {
    guard seenConceptCardLessonIds.insert(lessonId).inserted else { return }
    UserDefaults.standard.set(Array(seenConceptCardLessonIds), forKey: conceptCardStorageKey)
  }
}
