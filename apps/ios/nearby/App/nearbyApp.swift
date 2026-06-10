//
//  nearbyApp.swift
//  nearby
//
//  Created by Peter Anyaogu on 5/20/26.
//

import GoogleSignIn
import SwiftUI

@main
struct nearbyApp: App {
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onOpenURL { url in
          _ = GIDSignIn.sharedInstance.handle(url)
        }
        .onChange(of: scenePhase) { _, phase in
          guard phase == .active else { return }
          NotificationCenter.default.post(name: .nearbyAppDidBecomeActive, object: nil)
        }
    }
  }
}

extension Notification.Name {
  static let nearbyAppDidBecomeActive = Notification.Name("nearbyAppDidBecomeActive")
}
