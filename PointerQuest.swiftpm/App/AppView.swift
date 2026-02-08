import SwiftUI

struct AppView: View {
  @AppStorage("isOnboardingWatched") var isOnboardingWatched: Bool?
  @State private var isWelcomePresented = false
  
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
      WelcomeView(isPresented: $isWelcomePresented)
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
