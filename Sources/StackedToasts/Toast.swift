import SwiftUI

/// A single toast. Colors and symbol are per-toast; everything else comes from ``ToastStyle``.
public struct Toast: Identifiable, Hashable {
    public var id: String
    public var symbol: String?
    public var title: String
    public var message: String?
    public var tint: Color
    /// Automatically dismiss after this many seconds. `nil` keeps the toast until swiped away.
    public var autoDismissInterval: Double?

    public init(
        id: String = UUID().uuidString,
        symbol: String? = nil,
        title: String,
        message: String? = nil,
        tint: Color = .accentColor,
        autoDismissInterval: Double? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.message = message
        self.tint = tint
        self.autoDismissInterval = autoDismissInterval
    }
}

// MARK: - Presets

public extension Toast {
    static func success(_ title: String, message: String? = nil, tint: Color = .green, autoDismiss: Double? = 3) -> Toast {
        Toast(symbol: "checkmark.circle.fill", title: title, message: message, tint: tint, autoDismissInterval: autoDismiss)
    }

    static func error(_ title: String, message: String? = nil, tint: Color = .red, autoDismiss: Double? = nil) -> Toast {
        Toast(symbol: "xmark.octagon.fill", title: title, message: message, tint: tint, autoDismissInterval: autoDismiss)
    }

    static func warning(_ title: String, message: String? = nil, tint: Color = .orange, autoDismiss: Double? = 4) -> Toast {
        Toast(symbol: "exclamationmark.triangle.fill", title: title, message: message, tint: tint, autoDismissInterval: autoDismiss)
    }

    static func info(_ title: String, message: String? = nil, tint: Color = .blue, autoDismiss: Double? = 3) -> Toast {
        Toast(symbol: "info.circle.fill", title: title, message: message, tint: tint, autoDismissInterval: autoDismiss)
    }
}
