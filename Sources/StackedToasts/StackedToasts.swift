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
        .swipeActionsContainer()
        .background {
            if style.showsEdgeBlur {
                ScrollView(.vertical) { }
                    .frame(height: 0)
                    .allowsHitTesting(false)
                    .safeAreaBar(edge: .bottom, spacing: 0) {
                        Text(" ")
                            .frame(maxWidth: .infinity)
                            .frame(height: containerHeight)
                    }
                    .scrollEdgeEffectStyle(.soft, for: .bottom)
                    .opacity(toasts.isEmpty ? 0 : 1)
            }
        }
        .animation(style.animation, value: toasts)
        .padding(.bottom, style.bottomPadding)
    }
}

struct ToastView: View {
    var toast: Toast
    var style: ToastStyle
    var onDismiss: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: style.contentSpacing) {
            if let symbol = toast.symbol {
                Image(systemName: symbol)
                    .font(style.symbolFont)
                    .foregroundStyle(symbolStyle)
            }

            VStack(alignment: .leading, spacing: style.textSpacing) {
                Text(toast.title)
                    .font(style.titleFont)
                    .foregroundStyle(style.titleColor)

                if let message = toast.message {
                    Text(message)
                        .font(style.messageFont)
                        .foregroundStyle(style.messageColor)
                }
            }
            .lineLimit(style.lineLimit)
        }
        .padding(.horizontal, style.horizontalPadding)
        .frame(maxWidth: style.maxWidth, alignment: .leading)
        .frame(height: style.height)
        .background { tintGradient }
        .modifier(ToastBackground(style: style, tint: glassTint))
        .contentShape(style.shape.shape)
        .compositingGroup()
        .shadow(color: style.shadowColor, radius: style.shadowRadius, x: style.shadowOffset.width, y: style.shadowOffset.height)
        .swipeActions(edge: .trailing, allowsFullSwipe: style.allowsFullSwipe) {
            Button(action: onDismiss) {
                Image(systemName: style.swipeSymbol)
            }
            .tint(style.swipeTint ?? toast.tint)
        }
        .task {
            guard let interval = toast.autoDismissInterval else { return }
            try? await Task.sleep(for: .seconds(interval))
            if !Task.isCancelled { onDismiss() }
        }
    }

    private var symbolStyle: AnyShapeStyle {
        let color = style.symbolColor ?? toast.tint
        return style.symbolUsesGradient ? AnyShapeStyle(color.gradient) : AnyShapeStyle(color)
    }

    private var glassTint: Color {
        (style.glassTintColor ?? (colorScheme == .dark ? .black : .white)).opacity(style.glassTintOpacity)
    }

    @ViewBuilder
    private var tintGradient: some View {
        if style.showsTintGradient {
            let row1 = Array(repeating: toast.tint.opacity(style.topGradientOpacity), count: 3)
            let row2 = Array(repeating: toast.tint.opacity(style.middleGradientOpacity), count: 3)
            let row3 = Array(repeating: Color.clear, count: 3)
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: row1 + row2 + row3
            )
            .clipShape(style.shape.shape)
        }
    }
}

private struct ToastBackground: ViewModifier {
    var style: ToastStyle
    var tint: Color

    func body(content: Content) -> some View {
        if style.usesGlass {
            content.glassEffect(.regular.tint(tint), in: style.shape.shape)
        } else {
            content.background(style.solidBackground, in: style.shape.shape)
        }
    }
}
