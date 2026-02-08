import SwiftUI

struct AppView: View {
  @AppStorage("isOnboardingWatched") var isOnboardingWatched: Bool?
  @State private var isWelcomePresented = false
  @State private var isOnboardingPresented = false
  @State private var isAlertPresented = false
  
  var body: some View {
    TabView {
      MainView()
        .tabItem {
          Image(systemName: "house")
          Text("Home")
        }
      
      SettingView()
        .tabItem {
          Image(systemName: "gearshape.fill")
          Text("Setting")
        }
    }
    .popover(isPresented: $isWelcomePresented) {
      WelcomeView(
        isPresented: $isWelcomePresented,
        isOnboardingPresented: $isOnboardingPresented,
        isAlertPresented: $isAlertPresented
      )
    }
    .sheet(isPresented: $isOnboardingPresented) {
      OnboardingView()
    }
    .alert(
      "앱 사용법은 Setting > 앱 사용방법에서 다시 확인 가능합니다.",
      isPresented: $isAlertPresented
    ) {
      Button("Confirm", role: .cancel) { }
    }
    .onAppear {
      if isOnboardingWatched != true {
        isWelcomePresented = true
        isOnboardingWatched = true
      }
      
      isOnboardingWatched = false
    }
  }
}

#Preview {
  AppView()
}
