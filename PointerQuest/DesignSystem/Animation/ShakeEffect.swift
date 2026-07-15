import SwiftUI

/// 좌우로 흔들리는 효과를 주는 GeometryEffect
struct ShakeEffect: GeometryEffect {
  var animatableData: CGFloat
  
  func effectValue(size: CGSize) -> ProjectionTransform {
    ProjectionTransform(
      CGAffineTransform(
        translationX: 10 * sin(animatableData * .pi * CGFloat(3)),
        y: 0
      )
    )
  }
}
