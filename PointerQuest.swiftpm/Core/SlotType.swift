/// 메모리 슬롯의 역할
enum SlotType {
  /// 일반 변수
  case value
  /// 주소값
  case pointer
  /// 빈 공간
  case empty
}
