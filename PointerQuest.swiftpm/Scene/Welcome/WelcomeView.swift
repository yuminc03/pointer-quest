import SwiftUI

struct WelcomeView: View {
  @Binding var isPresented: Bool
  @Binding var isOnboardingPresented: Bool
  @Binding var isAlertPresented: Bool
  
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
          .padding(.bottom, 20)
      }
      
      CloseButton
        .padding(.top, 20)
        .padding(.trailing, 20)
    }
  }
}

private extension WelcomeView {
  var CloseButton: some View {
    Button {
      isAlertPresented = true
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
      Text("Welcome!")
        .fontWeight(.bold)
      
      Text("New to the app? Check out the tutorial to learn how to use it!")
        .multilineTextAlignment(.center)
    }
    .font(.callout)
  }
  
  var ButtonSection: some View {
    VStack(spacing: 20) {
      Button {
        isOnboardingPresented = true
        isPresented = false
      } label: {
        Text("Yes, show me the tutorial.")
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
        isAlertPresented = true
        isPresented = false
      } label: {
        Text("No, I'm good.")
          .font(.body)
          .fontWeight(.bold)
          .padding(.vertical, 16)
          .frame(maxWidth: .infinity)
          .background(
            Capsule()
              .fill(.background)
          )
      }
    }
  }
}

#Preview {
  WelcomeView(
    isPresented: .constant(true),
    isOnboardingPresented: .constant(false),
    isAlertPresented: .constant(false)
  )
}
