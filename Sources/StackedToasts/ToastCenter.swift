import SwiftUI
import Observation

/// Observable store you call from anywhere to show toasts.
@MainActor
@Observable
public final class ToastCenter {
    public var toasts: [Toast] = []

    public init() {}

    @discardableResult
    public func show(_ toast: Toast) -> String {
        toasts.append(toast)
        return toast.id
    }

    public func dismiss(id: String) {
        toasts.removeAll { $0.id == id }
    }

    public func dismissAll() {
        toasts.removeAll()
    }
}

public extension View {
    /// Overlays a toast stack driven by a ``ToastCenter``.
    func toastOverlay(_ center: ToastCenter, alignment: Alignment = .bottom) -> some View {
        modifier(ToastOverlayModifier(center: center, alignment: alignment))
    }

    /// Overlays a toast stack driven by your own array.
    func toastOverlay(_ toasts: Binding<[Toast]>, alignment: Alignment = .bottom) -> some View {
        overlay(alignment: alignment) { StackedToasts(toasts: toasts) }
    }
}

private struct ToastOverlayModifier: ViewModifier {
    @Bindable var center: ToastCenter
    var alignment: Alignment

    func body(content: Content) -> some View {
        content
            .environment(center)
            .overlay(alignment: alignment) {
                StackedToasts(toasts: $center.toasts)
            }
    }
}
