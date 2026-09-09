import SwiftUI

/// 탭 바를 담는 앱의 최상위 화면
///
/// 강조색은 여기서 지정하지 않는다. `.tint`는 뷰 계층을 타고 내려가는데 시트는 별도 계층으로
/// 올라와 전파되지 않아, 온보딩·개념 카드 같은 시트 안이 시스템 파랑으로 남았다.
/// 대신 자산 카탈로그의 전역 강조색(`ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME`)을 쓴다 —
/// 시트와 알럿까지 한 번에 덮인다
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
