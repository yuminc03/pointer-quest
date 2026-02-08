import SwiftUI

struct WelcomeView: View {
  @Binding var isPresented: Bool
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      VStack(spacing: 30) {
        OnboardingImage
          .ignoresSafeArea(.all)
        
        Cotents
          .padding(.horizontal, 20)
        
        Spacer()
        
        ButtonSection
          .padding(.horizontal, 20)
      }
      
      CloseButton
        .padding(.top, 5)
        .padding(.trailing, 20)
    }
  }
}

private extension WelcomeView {
  var CloseButton: some View {
    Button {
      isPresented = false
    } label: {
      Image(systemName: "xmark")
        .resizable()
        .frame(width: 20, height: 20)
        .padding(16)
        .background(.regularMaterial)
        .clipShape(Circle())
        .foregroundStyle(.black)
    }
  }
  
  var OnboardingImage: some View {
    Image(.welcome)
      .resizable()
      .aspectRatio(contentMode: .fit)
  }
  
  var Cotents: some View {
    VStack(spacing: 20) {
      Text("환영합니다!")
        .fontWeight(.bold)
      
      Text("앱을 처음 설치하셨다면 어떻게 사용하는지 설명을 먼저 보시면 어떨까요?")
        .multilineTextAlignment(.center)
    }
    .font(.callout)
  }
  
  var ButtonSection: some View {
    VStack(spacing: 20) {
      Button {
        
      } label: {
        Text("네, 사용방법을 볼게요.")
          .foregroundStyle(.white)
          .font(.body)
          .fontWeight(.bold)
          .padding(.vertical, 16)
          .frame(maxWidth: .infinity)
          .background(
            Capsule()
              .fill(Color(.main))
          )
      }
      
      Button {
        isPresented = false
      } label: {
        Text("아니요, 괜찮습니다.")
          .font(.body)
          .fontWeight(.bold)
          .padding(.vertical, 16)
          .frame(maxWidth: .infinity)
          .background(
            Capsule()
              .fill(.white)
          )
      }
    }
  }
}

#Preview {
  WelcomeView(isPresented: .constant(true))
}
