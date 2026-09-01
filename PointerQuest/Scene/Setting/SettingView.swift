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
            Text("앱 사용법")
          }
        }

        Section {
          LanguageRow
        } header: {
          Text("언어")
        } footer: {
          Text("설정에서 언어를 바꾸면 앱이 다시 시작됩니다.")
        }
      }
      .navigationTitle("설정")
      .sheet(isPresented: $isOnboardingPresented) {
        OnboardingView()
      }
    }
  }

  /// iOS 설정 앱의 이 앱 페이지(앱별 언어 설정이 있는 곳)로 이동
  private func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }
}

private extension SettingView {
  var LanguageRow: some View {
    Button {
      openAppSettings()
    } label: {
      HStack {
        Text("표시 언어")
          .foregroundStyle(.primary)

        Spacer()

        Text(AppLanguage.current.displayName)
          .foregroundStyle(.secondary)

        Image(systemName: "chevron.right")
          .font(.footnote.bold())
          .foregroundStyle(.tertiary)
      }
    }
  }
}

#Preview {
  SettingView()
}
