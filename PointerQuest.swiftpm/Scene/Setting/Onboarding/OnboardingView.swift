import SwiftUI

/// Onboarding 화면
struct OnboardingView: View {
  var body: some View {
    VStack(spacing: 20) {
      CapsuleView
        .padding(.top, 20)
      
      ScrollView(.vertical) {
        LazyVStack(spacing: 20) {
          Title
          
          TopSection
          
          Section1
          
          Section2
          
          Section3
        }
        .padding(.horizontal, 20)
      }
    }
  }
}

private extension OnboardingView {
  var CapsuleView: some View {
    Rectangle()
      .frame(width: 40, height: 5)
      .foregroundColor(Color(.lightGray).opacity(0.3))
      .clipShape(Capsule())
  }
  
  var Title: some View {
    Text("How to use")
      .font(.title)
      .fontWeight(.bold)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  var TopSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("When you select a Level and enter the next screen, you will see a screen with blocks arranged in a grid.")
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Text("In this screen, you can reference a block containing a specific value with another block.")
      
      Image(.onboarding1)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .font(.body)
  }
  
  var Section1: some View {
    section(
      text: "1. Long press a block to see it pop out in 3D.",
      image: .onboarding2
    )
  }
  
  var Section2: some View {
    section(
      text: "2. Drag it close to another block.",
      image: .onboarding3
    )
  }
  
  var Section3: some View {
    section(
      text: "3. Release your finger to connect the two blocks.",
      image: .onboarding4
    )
  }
  
  private func section(text: String, image: ImageResource) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(text)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Image(image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
  }
}

#Preview {
  OnboardingView()
}
