import Foundation

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
