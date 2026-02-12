import UIKit

extension UIDevice {
  /// 현재 기기가 iPhone인지 판별
  static var isIOS: Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
  }
}
