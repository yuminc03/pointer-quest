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
          Text("홈")
        }

      SettingView()
        .tabItem {
          Image(systemName: "gearshape.fill")
          Text("설정")
        }
    }
    .sheet(isPresented: $isWelcomePresented) {
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
      "튜토리얼은 설정 > 앱 사용법에서 다시 확인할 수 있습니다.",
      isPresented: $isAlertPresented
    ) {
      Button("확인", role: .cancel) { }
    }
    .onAppear {
      if isOnboardingWatched != true {
        isWelcomePresented = true
        isOnboardingWatched = true
      }
    }
  }
}

#Preview {
  AppView()
}
