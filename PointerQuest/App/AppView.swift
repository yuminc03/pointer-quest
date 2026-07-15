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
      "You can check the tutorial again in Setting > How to use the app.",
      isPresented: $isAlertPresented
    ) {
      Button("Confirm", role: .cancel) { }
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
