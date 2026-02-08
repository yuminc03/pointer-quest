import SwiftUI

struct AppView: View {
  @AppStorage("isOnboardingWatched") var isOnboardingWatched: Bool?
  @State private var isPresented = false
  
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
    .popover(isPresented: $isPresented) {
      WelcomeView(isPresented: $isPresented)
    }
    .onAppear {
      if isOnboardingWatched != true {
        isPresented = true
        isOnboardingWatched = true
      }
    }
  }
}

#Preview {
  AppView()
}
