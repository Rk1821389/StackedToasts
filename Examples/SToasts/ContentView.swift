//
//  ContentView.swift
//  SToasts
//

import SwiftUI
import StackedToasts

struct ContentView: View {
    enum Swipe: String, CaseIterable { case button = "Button", direct = "Direct", disabled = "Off" }
    enum Indicator: String, CaseIterable { case ring = "Ring", bar = "Bar", none = "None" }

    @State private var toasts = ToastCenter()
    @State private var glassOpacity: CGFloat = 0
    @State private var rounded = false
    @State private var swipe: Swipe = .button
    @State private var indicator: Indicator = .ring
    @State private var autoDismiss = true

    var body: some View {
        NavigationStack {
            List {
                Section("Style") {
                    Slider(value: $glassOpacity)
                    Toggle("Rounded rectangle", isOn: $rounded)
                    Toggle("Auto dismiss", isOn: $autoDismiss)
                    Picker("Countdown", selection: $indicator) {
                        ForEach(Indicator.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    Picker("Swipe", selection: $swipe) {
                        ForEach(Swipe.allCases, id: \.self) { Text($0.rawValue) }
                    }
                }
                Section("Show") {
                    Button("Success (auto 3s)") { toasts.show(.success("Saved", message: "Your changes are in")) }
                    Button("Error (stays)") { toasts.show(.error("Connection Failed", message: "Something went wrong")) }
                    Button("Warning (auto 6s)") { toasts.show(.warning("Low battery", autoDismiss: 6)) }
                    Button("Info (never auto-hides)") { toasts.show(.info("New version available", autoDismiss: nil)) }
                }
            }
            .navigationTitle("Toasts")
        }
        .toastOverlay(toasts)
        .toastStyle { s in
            s.glassTintOpacity = glassOpacity
            s.shape = rounded ? .roundedRectangle(cornerRadius: 16) : .capsule
            s.autoDismissEnabled = autoDismiss
            s.autoDismissIndicator = switch indicator {
            case .ring: .ring
            case .bar: .bar
            case .none: .none
            }
            s.swipeBehavior = switch swipe {
            case .button: .button
            case .direct: .direct
            case .disabled: .disabled
            }
        }
    }
}

#Preview {
    ContentView()
}
