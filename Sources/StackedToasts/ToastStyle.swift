import SwiftUI

/// Every visual and behavioral knob of the toast stack.
///
/// Start from ``ToastStyle/default`` and override what you need:
/// ```swift
/// var style = ToastStyle()
/// style.shape = .roundedRectangle(cornerRadius: 16)
/// style.titleFont = .headline
/// ContentView().toastStyle(style)
/// ```
public struct ToastStyle {

    // MARK: Layout
    public var height: CGFloat = 65
    public var maxWidth: CGFloat = 310
    public var horizontalPadding: CGFloat = 20
    public var contentSpacing: CGFloat = 15
    public var textSpacing: CGFloat = 4
    public var shape: ToastShape = .capsule
    /// Space between the toast and the bottom of the container.
    public var bottomPadding: CGFloat = 1

    // MARK: Typography & colors
    public var symbolFont: Font = .title
    public var titleFont: Font = .callout
    public var messageFont: Font = .caption2
    public var titleColor: Color = .primary
    public var messageColor: Color = .secondary
    /// `nil` uses the toast's `tint`. Set to force one symbol color for all toasts.
    public var symbolColor: Color? = nil
    public var symbolUsesGradient: Bool = true
    public var lineLimit: Int? = 1

    // MARK: Background
    /// Strength of the white (light) / black (dark) tint over the glass.
    public var glassTintOpacity: CGFloat = 0
    /// Overrides the light/dark glass tint color when set.
    public var glassTintColor: Color? = nil
    public var usesGlass: Bool = true
    /// Used instead of glass when `usesGlass` is false.
    public var solidBackground: Color = Color(.secondarySystemBackground)
    /// The soft tinted mesh gradient. Set both opacities to 0 or `showsTintGradient` to false to remove it.
    public var showsTintGradient: Bool = true
    public var topGradientOpacity: CGFloat = 0.15
    public var middleGradientOpacity: CGFloat = 0.10

    // MARK: Shadow
    public var shadowColor: Color = .black.opacity(0.06)
    public var shadowRadius: CGFloat = 5
    public var shadowOffset: CGSize = CGSize(width: 0, height: 10)

    // MARK: Stack
    /// How many toasts peek out behind the front one.
    public var maxStackedBehind: Int = 2
    /// Vertical peek of each toast behind the front one.
    public var stackOffset: CGFloat = 10
    /// Scale reduction per level behind the front toast.
    public var stackScaleStep: CGFloat = 0.05
    /// Soft blur fading content under the stack.
    public var showsEdgeBlur: Bool = true

    // MARK: Interaction
    public var swipeSymbol: String = "checkmark"
    /// `nil` uses the toast's `tint`.
    public var swipeTint: Color? = nil
    public var allowsFullSwipe: Bool = true

    // MARK: Animation & transitions
    public var animation: Animation = .smooth(duration: 0.3, extraBounce: 0)
    public var insertion: AnyTransition = .offset(y: 500).combined(with: AnyTransition(.blurReplace))
    public var removal: AnyTransition = .move(edge: .leading).combined(with: AnyTransition(.blurReplace))

    public init() {}

    public static let `default` = ToastStyle()
}

/// Shape of the toast. Use a built-in case or `custom` for any `Shape`.
public struct ToastShape {
    var shape: AnyShape

    public static var capsule: ToastShape { .init(shape: AnyShape(.capsule)) }
    public static func roundedRectangle(cornerRadius: CGFloat) -> ToastShape {
        .init(shape: AnyShape(.rect(cornerRadius: cornerRadius)))
    }
    public static func custom<S: Shape>(_ shape: S) -> ToastShape { .init(shape: AnyShape(shape)) }
}

// MARK: - Environment

private struct ToastStyleKey: EnvironmentKey {
    static let defaultValue = ToastStyle.default
}

public extension EnvironmentValues {
    var toastStyle: ToastStyle {
        get { self[ToastStyleKey.self] }
        set { self[ToastStyleKey.self] = newValue }
    }
}

public extension View {
    /// Applies a ``ToastStyle`` to every toast stack in this view hierarchy.
    func toastStyle(_ style: ToastStyle) -> some View {
        environment(\.toastStyle, style)
    }

    /// Modifies the current style in place.
    func toastStyle(_ transform: @escaping (inout ToastStyle) -> Void) -> some View {
        transformEnvironment(\.toastStyle, transform: transform)
    }
}
