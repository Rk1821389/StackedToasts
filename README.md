# StackedToasts

A SwiftUI stacked toast library with Liquid Glass, built so you can restyle everything to match your app's theme and design.

Toasts are stacked with a `ScrollView` + `visualEffect` instead of a `ZStack`, and support swipe-to-dismiss and auto-dismiss.

## Credits

Based on the tutorial by **Kavsoft**: [Stacked Toasts in SwiftUI](https://www.youtube.com/watch?v=4cLWzZ7_0Bk). All credit for the original idea and approach goes to Kavsoft.

## Requirements

iOS 27+, Xcode 27+ (uses `glassEffect`, `swipeActions` on any view, `safeAreaBar`).

## Installation

Swift Package Manager: `https://github.com/Rk1821389/SToasts`, product **StackedToasts**.

## Usage

```swift
import StackedToasts

struct RootView: View {
    @State private var toasts = ToastCenter()

    var body: some View {
        ContentView()
            .toastOverlay(toasts)
    }
}

// anywhere:
toasts.show(.success("Saved", message: "Your changes are in"))
toasts.show(Toast(symbol: "star.fill", title: "Custom", tint: .purple, autoDismissInterval: 5))
```

Prefer your own state? Use `.toastOverlay($toasts)` with `@State var toasts: [Toast]`.

## Theming

Everything lives in `ToastStyle`. Apply it once near the root (or per screen):

```swift
var style = ToastStyle()
style.shape = .roundedRectangle(cornerRadius: 14)
style.titleFont = .system(.headline, design: .rounded)
style.titleColor = .white
style.usesGlass = false
style.solidBackground = .indigo
style.showsTintGradient = false
style.maxStackedBehind = 3

RootView().toastStyle(style)

// or tweak in place:
RootView().toastStyle { $0.glassTintOpacity = 0.4 }
```

| Group | Options |
|---|---|
| Layout | `height`, `maxWidth`, `horizontalPadding`, `contentSpacing`, `textSpacing`, `shape`, `bottomPadding` |
| Typography & color | `symbolFont`, `titleFont`, `messageFont`, `titleColor`, `messageColor`, `symbolColor`, `symbolUsesGradient`, `lineLimit` |
| Background | `usesGlass`, `glassTintOpacity`, `glassTintColor`, `solidBackground`, `showsTintGradient`, `topGradientOpacity`, `middleGradientOpacity` |
| Shadow | `shadowColor`, `shadowRadius`, `shadowOffset` |
| Stack | `maxStackedBehind`, `stackOffset`, `stackScaleStep`, `showsEdgeBlur` |
| Interaction | `swipeSymbol`, `swipeTint`, `allowsFullSwipe` |
| Animation | `animation`, `insertion`, `removal` |

Built-in presets: `.success`, `.error`, `.warning`, `.info` (each takes a custom `tint`).

## Demo

Open `Examples/SToasts.xcodeproj`.
