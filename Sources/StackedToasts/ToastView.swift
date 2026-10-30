import SwiftUI

struct ToastView: View {
    var toast: Toast
    var style: ToastStyle
    var onDismiss: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    /// 1 → 0 over the auto-dismiss interval.
    @State private var remaining: CGFloat = 1

    private var autoDismissInterval: Double? {
        style.autoDismissEnabled ? toast.autoDismissInterval : nil
    }

    private var showsIndicator: Bool {
        autoDismissInterval != nil && style.autoDismissIndicator != .none
    }

    var body: some View {
        card
            .modifier(
                ToastSwipe(
                    behavior: style.swipeBehavior,
                    style: style,
                    tint: style.swipeTint ?? toast.tint,
                    onDismiss: onDismiss
                )
            )
            .task {
                guard let interval = autoDismissInterval else { return }
                if showsIndicator {
                    withAnimation(.linear(duration: interval)) { remaining = 0 }
                }
                try? await Task.sleep(for: .seconds(interval))
                if !Task.isCancelled { onDismiss() }
            }
    }

    private var card: some View {
        HStack(spacing: style.contentSpacing) {
            if let symbol = toast.symbol {
                Image(systemName: symbol)
                    .font(style.symbolFont)
                    .foregroundStyle(symbolStyle)
                    .overlay { ringIndicator }
            }

            VStack(alignment: .leading, spacing: style.textSpacing) {
                Text(toast.title)
                    .font(style.titleFont)
                    .fontWeight(style.titleWeight)
                    .foregroundStyle(style.titleColor)

                if let message = toast.message {
                    Text(message)
                        .font(style.messageFont)
                        .fontWeight(style.messageWeight)
                        .foregroundStyle(style.messageColor)
                }
            }
            .lineLimit(style.lineLimit)
        }
        .fontDesign(style.fontDesign)
        .padding(.horizontal, style.horizontalPadding)
        .frame(maxWidth: style.maxWidth, alignment: .leading)
        .frame(height: style.height)
        .background { TintGradient(tint: toast.tint, style: style) }
        .overlay(alignment: .bottom) { barIndicator }
        .modifier(ToastBackground(style: style, tint: glassTint))
        .contentShape(style.shape.shape)
        .compositingGroup()
        .shadow(color: style.shadowColor, radius: style.shadowRadius, x: style.shadowOffset.width, y: style.shadowOffset.height)
    }

    private var indicatorColor: Color { style.indicatorColor ?? toast.tint }

    @ViewBuilder
    private var ringIndicator: some View {
        if showsIndicator, style.autoDismissIndicator == .ring, toast.symbol != nil {
            Circle()
                .trim(from: 0, to: remaining)
                .stroke(indicatorColor, style: StrokeStyle(lineWidth: style.indicatorLineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(-8)
        }
    }

    @ViewBuilder
    private var barIndicator: some View {
        if showsIndicator, style.autoDismissIndicator == .bar {
            Capsule()
                .fill(indicatorColor)
                .frame(height: style.indicatorLineWidth)
                .scaleEffect(x: remaining, anchor: .leading)
                .padding(.horizontal, style.height / 2)
                .padding(.bottom, 6)
        }
    }

    private var symbolStyle: AnyShapeStyle {
        let color = style.symbolColor ?? toast.tint
        return style.symbolUsesGradient ? AnyShapeStyle(color.gradient) : AnyShapeStyle(color)
    }

    private var glassTint: Color {
        (style.glassTintColor ?? (colorScheme == .dark ? .black : .white)).opacity(style.glassTintOpacity)
    }
}

// MARK: - Background

private struct TintGradient: View {
    var tint: Color
    var style: ToastStyle

    @ViewBuilder
    var body: some View {
        if style.showsTintGradient {
            Group {
                if #available(iOS 18, *) {
                    let row1 = Array(repeating: tint.opacity(style.topGradientOpacity), count: 3)
                    let row2 = Array(repeating: tint.opacity(style.middleGradientOpacity), count: 3)
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
                } else {
                    LinearGradient(
                        colors: [tint.opacity(style.topGradientOpacity), tint.opacity(style.middleGradientOpacity), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .clipShape(style.shape.shape)
        }
    }
}

private struct ToastBackground: ViewModifier {
    var style: ToastStyle
    var tint: Color

    @ViewBuilder
    func body(content: Content) -> some View {
        if !style.usesGlass {
            content.background(style.solidBackground, in: style.shape.shape)
        } else if #available(iOS 26, *) {
            content.glassEffect(.regular.tint(tint), in: style.shape.shape)
        } else {
            // Liquid Glass is iOS 26+; blurred material is the closest older equivalent.
            content
                .background(.ultraThinMaterial, in: style.shape.shape)
                .background(tint, in: style.shape.shape)
        }
    }
}

// MARK: - Swipe

private struct ToastSwipe: ViewModifier {
    var behavior: ToastSwipeBehavior
    var style: ToastStyle
    var tint: Color
    var onDismiss: () -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        switch behavior {
        case .disabled:
            content
        case .button:
            if #available(iOS 27, *) {
                content.swipeActions(edge: .trailing, allowsFullSwipe: style.allowsFullSwipe) {
                    Button(action: onDismiss) { Image(systemName: style.swipeSymbol) }
                        .tint(tint)
                }
            } else {
                content.modifier(DragToDismiss(showsButton: true, style: style, tint: tint, onDismiss: onDismiss))
            }
        case .direct:
            content.modifier(DragToDismiss(showsButton: false, style: style, tint: tint, onDismiss: onDismiss))
        }
    }
}

/// Custom swipe used for `.direct`, and for `.button` where `swipeActions` can't be used on a plain view (before iOS 27).
private struct DragToDismiss: ViewModifier {
    var showsButton: Bool
    var style: ToastStyle
    var tint: Color
    var onDismiss: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isRevealed = false

    private var buttonSize: CGFloat { style.height * 0.75 }
    private var revealWidth: CGFloat { buttonSize + 10 }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .trailing) {
                if showsButton {
                    Button(action: onDismiss) {
                        Image(systemName: style.swipeSymbol)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: buttonSize, height: buttonSize)
                            .background(tint, in: .circle)
                    }
                    .buttonStyle(.plain)
                    .offset(x: revealWidth)
                    .opacity(min(1, max(0, -offset / revealWidth)))
                }
            }
            .offset(x: offset)
            .gesture(drag)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                let base = isRevealed ? -revealWidth : 0
                let raw = base + value.translation.width
                // Resist dragging to the right.
                offset = raw > 0 ? raw * 0.15 : raw
            }
            .onEnded { value in
                let projected = (isRevealed ? -revealWidth : 0) + value.predictedEndTranslation.width
                if showsButton {
                    if style.allowsFullSwipe, -offset > revealWidth * 2.2 || -projected > revealWidth * 4 {
                        onDismiss()
                    } else if -offset > revealWidth / 2 {
                        isRevealed = true
                        withAnimation(style.animation) { offset = -revealWidth }
                    } else {
                        isRevealed = false
                        withAnimation(style.animation) { offset = 0 }
                    }
                } else if -offset > style.maxWidth * 0.3 || -projected > style.maxWidth * 0.7 {
                    onDismiss()
                } else {
                    withAnimation(style.animation) { offset = 0 }
                }
            }
    }
}
