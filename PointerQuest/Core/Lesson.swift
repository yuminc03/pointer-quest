import Foundation

/// Pointer Quest의 레슨 데이터를 관리하는 정적 객체
struct LessonData {
  static let lessons: [Lesson] = [
    .init(
      id: 1,
      title: "The Importance of Address",
      description: "It's not the value, but the 'Address' that matters.\nDrag the pointer to point to address.",
      iconName: "map"
    ),
    .init(
      id: 2,
      title: "Stepping Stone Pointer",
      description: "Data is protected by a Lock system.\nConnect via the existing 'Link Pointer' instead of accessing directly.",
      iconName: "arrow.triangle.merge"
    ),
    .init(
      id: 3,
      title: "Chain Connection",
      description: "Create a path to reach the data.\nConnect in order: Start -> Node A -> Node B -> Treasure.",
      iconName: "link"
    )
  ]
}

/// Pointer Quest의 각 학습 레슨을 정의하는 데이터 모델
struct Lesson: Identifiable, Hashable {
  let id: Int
  /// 레슨 제목
  let title: String
  /// 레슨 상세설명
  let description: String
  /// 레슨 카드에 표시될 아이콘 또는 이미지 이름 (SF Symbol 등)
  let iconName: String
}

// TODO: Task 1 마이그레이션이 끝나면(모든 참조가 Lesson/LessonData로 전환되면) 제거
typealias Level = Lesson
typealias LevelData = LessonData
extension LessonData {
  static var levels: [Lesson] { lessons }
}
