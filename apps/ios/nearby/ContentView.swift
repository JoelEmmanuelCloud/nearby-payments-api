//
//  ContentView.swift
//  nearby
//
//  Created by Peter Anyaogu on 5/20/26.
//

import Gateway
import SwiftData
import SwiftUI
import UI

struct ContentView: View {
  @State private var message = ""

  @State private var gateway = APIGateway(
    configuration: GatewayConfiguration(baseURL: URL(string: "http://localhost:8080")!),
    httpClient: URLSessionHTTPClient()
  )

  var body: some View {
    VStack(spacing: 16) {
      Title("Nearby")

      Card {
        Text(message.isEmpty ? "Tap the button" : message)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      UIButton("Say Hello") {
        Task {
          do {
            let pubkey = try await gateway.serverPublicKey()
            message = pubkey.publicKey
          } catch {
            message = "gateway unreachable"
          }
        }
      }
    }
    .padding()
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
