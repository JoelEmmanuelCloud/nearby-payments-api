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
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onOpenURL { url in
          _ = GIDSignIn.sharedInstance.handle(url)
        }
    }
  }
}
