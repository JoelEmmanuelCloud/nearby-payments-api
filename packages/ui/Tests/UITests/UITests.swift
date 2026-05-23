import SwiftUI
import UI
import XCTest

final class UITests: XCTestCase {
  @MainActor
  func testToastCanBeConstructed() {
    _ = Toast(title: "Hello", tone: .success)
  }

  @MainActor
  func testButtonCanBeConstructed() {
    _ = UIButton("Continue") {}
  }
}
