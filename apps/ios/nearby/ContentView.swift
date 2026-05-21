//
//  ContentView.swift
//  nearby
//
//  Created by Peter Anyaogu on 5/20/26.
//

import Hello
import UI
import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var message = ""

    var body: some View {
        VStack(spacing: 16) {
            Title("Nearby")

            Card {
                Text(message.isEmpty ? "Tap the button" : message)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            UIButton("Say Hello") {
                message = Greeting.message()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
