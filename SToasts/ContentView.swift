//
//  ContentView.swift
//  SToasts
//
//  Created by SRH on 30/10/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var glassTintOpacity: CGFloat = 0
    @State private var containerToasts: [Toast] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section("Glass Tint Opacity") {
                    Slider(value: $glassTintOpacity)
                }
                
                Section("Action") {
                    Button("Add Toasts", action: addToast)
                }
            }
            .navigationTitle("Toasts")
        }
        .overlay(alignment: .bottom) {
            StackedToasts(
                glassTintOpacity: glassTintOpacity,
                toasts: $containerToasts
            )
        }
    }
    
    func addToast() {
        let toast = Toast(
            symbol: "exclamationmark.triangle.fill",
            title: "Connection Failed",
            description: "Something went wrong",
            tintColor: .red
        )
        containerToasts.append(toast)
    }
}

#Preview {
    ContentView()
}
