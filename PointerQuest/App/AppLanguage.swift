import Foundation

/// 앱이 지원하는 표시 언어와 "재시작 필요" 방식의 전환 로직을 담당
enum AppLanguage: String, CaseIterable, Identifiable {
  case korean = "ko"
  case english = "en"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .korean: "한국어"
    case .english: "English"
    }
  }

  private static let appleLanguagesKey = "AppleLanguages"
  private static let hasSetInitialLanguageKey = "hasSetInitialLanguage"

  /// 사용자가 언어를 선택한 적이 없다면(최초 실행) 기기 시스템 언어와 무관하게 한국어를 기본값으로 적용
  static func applyInitialLanguageIfNeeded() {
    guard !UserDefaults.standard.bool(forKey: hasSetInitialLanguageKey) else { return }
    apply(.korean)
  }

  /// 사용자가 명시적으로 언어를 선택했을 때 호출. 적용에는 앱 재시작이 필요하다
  static func apply(_ language: AppLanguage) {
    UserDefaults.standard.set([language.rawValue], forKey: appleLanguagesKey)
    UserDefaults.standard.set(true, forKey: hasSetInitialLanguageKey)
  }

  static var current: AppLanguage {
    let languages = UserDefaults.standard.stringArray(forKey: appleLanguagesKey) ?? []
    guard let first = languages.first, let language = AppLanguage(rawValue: first) else {
      return .korean
    }
    return language
  }
}
