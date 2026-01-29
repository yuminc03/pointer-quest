import Foundation

/// 게임 내 레벨 데이터를 관리하는 정적 객체
struct LevelData {
  static let levels: [Level] = [
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

/// Pointer Quest의 각 게임 레벨을 정의하는 데이터 모델
struct Level: Identifiable, Hashable {
  let id: Int
  /// Level 제목
  let title: String
  /// Level 상세설명
  let description: String
  /// 레벨 카드에 표시될 아이콘 또는 이미지 이름 (SF Symbol 등)
  let iconName: String
}
