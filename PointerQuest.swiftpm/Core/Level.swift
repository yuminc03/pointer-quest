import Foundation

/// 게임 내 레벨 데이터를 관리하는 정적 객체
struct LevelData {
  static let levels: [Level] = [
    .init(
      id: 1,
      title: "Level 1: 주소의 중요성",
      description: "값이 아니라 '주소'가 중요합니다.\n포인터를 드래그하여 주소 0x700C를 가리키게 하세요.",
      iconName: "map"
    ),
    .init(
      id: 2,
      title: "Level 2: 징검다리 포인터",
      description: "데이터가 보안 시스템(Lock)으로 보호받고 있습니다.\n직접 접근하지 말고, 이미 연결된 '중계 포인터'를 찾아서 연결하세요.",
      iconName: "arrow.triangle.merge"
    ),
    .init(
      id: 3,
      title: "Level 3: 이중 포인터",
      description: "포인터도 메모리에 저장됩니다.\n포인터를 가리키는 포인터를 만들어보세요.",
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
