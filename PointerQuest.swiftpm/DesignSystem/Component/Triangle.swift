import SwiftUI

struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    // Start top-left
    path.move(to: CGPoint(x: 0, y: 0))
    // Point to the right (tip)
    path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
    // Bottom-left
    path.addLine(to: CGPoint(x: 0, y: rect.height))
    // Indent at the back to make it look like an arrowhead
    path.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.height / 2))
    
    path.closeSubpath()
    return path
  }
}


#Preview {
  Triangle()
}
