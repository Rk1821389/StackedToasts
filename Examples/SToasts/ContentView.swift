//
//  ContentView.swift
//  SToasts
//

import SwiftUI
import StackedToasts

struct ContentView: View {
    @State private var toasts = ToastCenter()
    @State private var glassOpacity: CGFloat = 0
    @State private var rounded = false

    var body: some View {
        NavigationStack {
            List {
                Section("Style") {
                    Slider(value: $glassOpacity)
                    Toggle("Rounded rectangle", isOn: $rounded)
                }
                Section("Show") {
                    Button("Success") { toasts.show(.success("Saved", message: "Your changes are in")) }
                    Button("Error") { toasts.show(.error("Connection Failed", message: "Something went wrong")) }
                    Button("Warning") { toasts.show(.warning("Low battery")) }
                    Button("Info") { toasts.show(.info("New version available")) }
                }
            }
            .navigationTitle("Toasts")
        }
        .toastOverlay(toasts)
        .toastStyle { s in
            s.glassTintOpacity = glassOpacity
            s.shape = rounded ? .roundedRectangle(cornerRadius: 16) : .capsule
        }
    }
}

#Preview {
    ContentView()
}
