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
    Text("사용방법")
      .font(.title)
      .fontWeight(.bold)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  var TopSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Level을 선택하고 다음 화면으로 들어간다면 격자 모양으로 블록들이 모인 화면이 나타납니다.")
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Text("이 화면에서 특정 값이 들어있는 블록을 다른 블록으로 참조할 수 있습니다.")
      
      Image(.onboarding1)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .font(.body)
  }
  
  var Section1: some View {
    section(
      text: "1. 블록 하나를 길게 누르면 입체적으로 튀어나오는 효과가 나타납니다.",
      image: .onboarding2
    )
  }
  
  var Section2: some View {
    section(
      text: "2. 그대로 드래그해서 다른 블록에게 가까이 옮기세요.",
      image: .onboarding3
    )
  }
  
  var Section3: some View {
    section(
      text: "3. 그리고 드래그를 멈추고 손을 화면에서 떼면 두 블록은 서로 연결된 것입니다.",
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
