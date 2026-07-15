import SwiftUI

/// 각 메모리 셀의 위치(Bounds)를 상위 뷰로 전달하기 위한 Key
struct BoundsPreferenceKey: PreferenceKey {
  nonisolated(unsafe) static var defaultValue: [UUID: Anchor<CGRect>] = [:]
  
  static func reduce(
    value: inout [UUID: Anchor<CGRect>],
    nextValue: () -> [UUID: Anchor<CGRect>]
  ) {
    // 하위 뷰들이 전달한 위치 정보들을 하나로 합침
    value.merge(nextValue()) { $1 }
  }
}
