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
            Text("앱 사용법")
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
          Text("언어")
        }
      }
      .navigationTitle("설정")
      .sheet(isPresented: $isOnboardingPresented) {
        OnboardingView()
      }
      .alert("재시작 필요", isPresented: $isRestartAlertPresented) {
        Button("확인", role: .cancel) { }
      } message: {
        Text("언어 변경 사항을 적용하려면 앱을 재시작해주세요.")
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
