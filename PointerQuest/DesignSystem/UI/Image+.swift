import SwiftUI

extension Image {
  /// 정사각형 모양 이미지 크기 지정
  func size(_ length: CGFloat) -> some View {
    self
      .resizable()
      .frame(width: length, height: length)
  }
}
