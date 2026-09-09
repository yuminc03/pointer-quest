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

        Section {
          PrivacyPolicyRow
        } footer: {
          Text("이 앱은 개인정보를 수집하지 않습니다. 학습 진행 상황은 기기에만 저장됩니다.")
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
  /// 개인정보처리방침 페이지 주소
  ///
  /// App Store Connect에 등록하는 주소와 같은 것을 쓴다. 앱 안에 방침 전문을 두지 않는 이유는
  /// 방침이 바뀔 때마다 앱을 새로 심사받게 되기 때문이다 — 웹 페이지는 고쳐서 바로 반영된다
  static let privacyPolicyURL = URL(string: "https://yuminc03.github.io/pointer-quest/privacy-policy.html")
}

private extension SettingView {
  var PrivacyPolicyRow: some View {
    Button {
      guard let url = Self.privacyPolicyURL else { return }
      UIApplication.shared.open(url)
    } label: {
      HStack {
        Text("개인정보처리방침")
          .foregroundStyle(.primary)

        Spacer()

        Image(systemName: "arrow.up.right.square")
          .font(.footnote.bold())
          .foregroundStyle(.tertiary)
      }
    }
  }

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
