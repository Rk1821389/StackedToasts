import SwiftUI

/// The stacked toast view. Style it with `.toastStyle(_:)`.
public struct StackedToasts: View {
    @Binding var toasts: [Toast]
    @Environment(\.toastStyle) private var style

    public init(toasts: Binding<[Toast]>) {
        self._toasts = toasts
    }

    public var body: some View {
        let behind = max(style.maxStackedBehind, 1)
        // Extra room so toasts peeking behind the front one are not clipped.
        let slack = style.stackOffset * CGFloat(behind) + 5
        let containerHeight = style.height + slack

        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(toasts.reversed()) { toast in
                    let index = toasts.firstIndex(of: toast) ?? 0
                    ToastView(toast: toast, style: style) {
                        toasts.removeAll(where: { $0.id == toast.id })
                    }
                    .visualEffect { [style, behind] content, proxy in
                        let minY = proxy.frame(in: .scrollView).minY
                        let progress = minY / style.height
                        let offset = min(progress * style.stackOffset, style.stackOffset * CGFloat(behind))
                        let scale = min(progress * style.stackScaleStep, style.stackScaleStep * CGFloat(behind))
                        return content
                            .scaleEffect(1 - scale, anchor: .bottom)
                            .offset(y: -minY)
                            .offset(y: offset)
                    }
                    .zIndex(Double(index))
                    .transition(.asymmetric(insertion: style.insertion, removal: style.removal))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDisabled(true)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .frame(height: containerHeight)
        .offset(y: slack - max(min(CGFloat(toasts.count - 1) * slack / CGFloat(behind), slack), 0))
        .modifier(SwipeActionsContainer(enabled: style.swipeBehavior == .button))
        .background {
            EdgeBlur(isVisible: style.showsEdgeBlur && !toasts.isEmpty, height: containerHeight)
        }
        .animation(style.animation, value: toasts)
        .padding(.bottom, style.bottomPadding)
    }
}

// MARK: - Availability wrappers

/// iOS 27+: lets `swipeActions` work on a plain view.
private struct SwipeActionsContainer: ViewModifier {
    var enabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled, #available(iOS 27, *) {
            content.swipeActionsContainer()
        } else {
            content
        }
    }
}

/// iOS 26+: soft blur fading content under the stack.
private struct EdgeBlur: View {
    var isVisible: Bool
    var height: CGFloat

    @ViewBuilder
    var body: some View {
        if #available(iOS 26, *) {
            ScrollView(.vertical) { }
                .frame(height: 0)
                .allowsHitTesting(false)
                .safeAreaBar(edge: .bottom, spacing: 0) {
                    Text(" ")
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                }
                .scrollEdgeEffectStyle(.soft, for: .bottom)
                .opacity(isVisible ? 1 : 0)
        }
    }
}
