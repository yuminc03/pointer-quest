import SwiftUI

struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
    path.addLine(to: CGPoint(x: 0, y: rect.height))
    path.closeSubpath()
    return path
  }
}


#Preview {
  Triangle()
}
