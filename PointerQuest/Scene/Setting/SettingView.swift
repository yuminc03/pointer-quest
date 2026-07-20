import SwiftUI

struct SettingView: View {
  @State private var isOnboardingPresented = false
  @State private var selectedLanguage = AppLanguage.current
  @State private var isRestartAlertPresented = false

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

        Section {
          ForEach(AppLanguage.allCases) { language in
            Button {
              selectLanguage(language)
            } label: {
              HStack {
                Text(language.displayName)
                  .foregroundStyle(.primary)

                Spacer()

                if selectedLanguage == language {
                  Image(systemName: "checkmark")
                    .foregroundStyle(Color(.main))
                }
              }
            }
          }
        } header: {
          Text("Language")
        }
      }
      .navigationTitle("Setting")
      .sheet(isPresented: $isOnboardingPresented) {
        OnboardingView()
      }
      .alert("Restart Required", isPresented: $isRestartAlertPresented) {
        Button("Confirm", role: .cancel) { }
      } message: {
        Text("Please restart the app to apply the language change.")
      }
    }
  }

  private func selectLanguage(_ language: AppLanguage) {
    guard language != selectedLanguage else { return }
    selectedLanguage = language
    AppLanguage.apply(language)
    isRestartAlertPresented = true
  }
}

#Preview {
  SettingView()
}
