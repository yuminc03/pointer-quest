import SwiftUI
import UIKit

struct PageControl: UIViewRepresentable {
  let numberOfPages: Int
  @Binding var currentPage: Int
  
  func makeUIView(context: Context) -> UIPageControl {
    let v = UIPageControl()
    v.pageIndicatorTintColor = .systemBlue.withAlphaComponent(0.3)
    v.currentPageIndicatorTintColor = .systemBlue
    v.numberOfPages = numberOfPages
    v.addTarget(
      context.coordinator,
      action: #selector(Coordinator.didChangePage(sender:)),
      for: .valueChanged
    )
    
    return v
  }
  
  func updateUIView(_ uiView: UIPageControl, context: Context) {
    uiView.currentPage = currentPage
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
  }
  
  @MainActor
  final class Coordinator: NSObject {
    private var parent: PageControl
    
    init(parent: PageControl) {
      self.parent = parent
    }
    
    @objc func didChangePage(sender: UIPageControl) {
      parent.currentPage = sender.currentPage
    }
  }
}

#Preview {
  PageControl(numberOfPages: 3, currentPage: .constant(0))
}
