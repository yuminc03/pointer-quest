import SwiftUI

struct SettingView: View {
  @State private var isOnboardingPresented = false
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          Button {
            isOnboardingPresented.toggle()
          } label: {
            Text("How to use the app")
          }
        }
      }
      .navigationTitle("Setting")
      .sheet(isPresented: $isOnboardingPresented) {
        OnboardingView()
      }
    }
  }
}

#Preview {
  SettingView()
}
