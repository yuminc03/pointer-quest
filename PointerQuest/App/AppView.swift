import SwiftUI

/// 탭 바를 담는 앱의 최상위 화면
///
/// 강조색을 여기서 한 번 지정한다. 지정하지 않으면 탭 바·버튼·링크가 시스템 기본 파랑을 쓰는데,
/// 브랜드 색과 미묘하게 다른 파랑이라 한 화면에 두 가지 파랑이 함께 보인다
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
    .tint(Color(.main))
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
