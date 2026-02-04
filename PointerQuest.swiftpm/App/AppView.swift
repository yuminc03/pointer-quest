import SwiftUI

struct AppView: View {
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
  }
}

#Preview {
  AppView()
}
