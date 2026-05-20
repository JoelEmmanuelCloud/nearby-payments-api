import XCTest
import SwiftUI
import UI

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
