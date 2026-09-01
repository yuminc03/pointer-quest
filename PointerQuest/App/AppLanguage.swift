import Foundation

/// 앱에 현재 적용된 표시 언어. 언어 변경 자체는 iOS 앱별 언어 설정에 위임한다
enum AppLanguage: String {
  case korean = "ko"
  case english = "en"

  var displayName: String {
    switch self {
    case .korean: "한국어"
    case .english: "English"
    }
  }

  /// 번들이 실제로 로드한 로컬라이제이션 기준의 현재 언어
  /// 지원 목록에 없는 값이면 개발 지역(`ko`)이 적용된 것으로 본다
  static var current: AppLanguage {
    let code = Bundle.main.preferredLocalizations.first ?? ""
    return AppLanguage(rawValue: code) ?? .korean
  }
}
