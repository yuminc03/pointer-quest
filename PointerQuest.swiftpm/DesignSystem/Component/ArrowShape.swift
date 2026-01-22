import SwiftUI

/// 시작점과 끝점을 연결하는 화살표 모양 (애니메이션 지원)
struct ArrowShape: Shape {
  var startPoint: CGPoint
  var endPoint: CGPoint
  
  // 애니메이션을 위해 AnimatableData 구현
  var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
    get {
      AnimatablePair(startPoint.animatableData, endPoint.animatableData)
    }
    set {
      startPoint.animatableData = newValue.first
      endPoint.animatableData = newValue.second
    }
  }
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: startPoint)
    
    // 곡선(Bezier Curve)으로 부드럽게 연결
    let control1 = CGPoint(x: startPoint.x, y: (startPoint.y + endPoint.y) / 2)
    let control2 = CGPoint(x: endPoint.x, y: (startPoint.y + endPoint.y) / 2)
    
    
    path.addCurve(to: endPoint, control1: control1, control2: control2)
    
    return path
  }
}
