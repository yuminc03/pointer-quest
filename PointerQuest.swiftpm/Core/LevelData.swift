import Foundation

/// 게임 내 레벨 데이터를 관리하는 정적 객체
struct LevelData {
  static let levels: [Level] = [
    .init(
      id: 1,
      title: "Level 1: 주소 찾기",
      description: "메모리의 기본 개념인 '주소'를 이해하세요.\n값이 들어있는 방번호를 찾아보세요.",
      iconName: "map"
    ),
    .init(
      id: 2,
      title: "Level 2: 포인터 연결",
      description: "포인터 변수를 만들고 값(Value)을 가리키게(Reference) 해보세요.",
      iconName: "arrow.triangle.branch"
    ),
    .init(
      id: 3,
      title: "Level 3: 이중 포인터",
      description: "포인터도 메모리에 저장됩니다.\n포인터를 가리키는 포인터를 만들어보세요.",
      iconName: "link"
    )
  ]
}
