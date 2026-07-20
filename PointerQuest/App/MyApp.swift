import SwiftUI

@main
struct MyApp: App {
  init() {
    AppLanguage.applyInitialLanguageIfNeeded()
  }

  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}
