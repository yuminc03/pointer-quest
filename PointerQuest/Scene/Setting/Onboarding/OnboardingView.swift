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
    Text("사용 방법")
      .font(.title)
      .fontWeight(.bold)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  var TopSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("레슨을 선택해 다음 화면으로 이동하면, 격자 모양으로 배치된 블록 화면을 보게 됩니다.")
        .frame(maxWidth: .infinity, alignment: .leading)

      Text("이 화면에서는 특정 값을 가진 블록을 다른 블록으로 참조(가리키게)할 수 있습니다.")
      
      Image(.onboarding1)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .font(.body)
  }
  
  var Section1: some View {
    section(
      text: "1. 블록을 길게 누르면 3D로 튀어나오는 모습을 볼 수 있어요.",
      image: .onboarding2
    )
  }
  
  var Section2: some View {
    section(
      text: "2. 다른 블록 가까이로 드래그하세요.",
      image: .onboarding3
    )
  }
  
  var Section3: some View {
    section(
      text: "3. 손가락을 떼면 두 블록이 연결됩니다.",
      image: .onboarding4
    )
  }
  
  private func section(
    text: LocalizedStringKey,
    image: ImageResource
  ) -> some View {
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
