# StackedToasts

A SwiftUI stacked toast library with Liquid Glass, built so you can restyle everything to match your app's theme and design.

Toasts are stacked with a `ScrollView` + `visualEffect` instead of a `ZStack`, and support swipe-to-dismiss and auto-dismiss.

## Credits

Based on the tutorial by **Kavsoft**: [Stacked Toasts in SwiftUI](https://www.youtube.com/watch?v=4cLWzZ7_0Bk). All credit for the original idea and approach goes to Kavsoft.

## Requirements

iOS 17+ (Xcode 27+ to build). Newer OS features are used when available and fall back gracefully:

| OS | Background | Swipe button | Edge blur |
|---|---|---|---|
| iOS 27+ | Liquid Glass | native `swipeActions` | yes |
| iOS 26 | Liquid Glass | custom drag | yes |
| iOS 18 | blurred material | custom drag | no |
| iOS 17 | blurred material, linear tint gradient | custom drag | no |

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
| Typography & color | `symbolFont`, `titleFont`, `messageFont`, `titleColor`, `messageColor`, `symbolColor`, `symbolUsesGradient`, `lineLimit`, `fontDesign`, `titleWeight`, `messageWeight`, `setFont(_:)` |
| Background | `usesGlass`, `glassTintOpacity`, `glassTintColor`, `solidBackground`, `showsTintGradient`, `topGradientOpacity`, `middleGradientOpacity` |
| Shadow | `shadowColor`, `shadowRadius`, `shadowOffset` |
| Stack | `maxStackedBehind`, `stackOffset`, `stackScaleStep`, `showsEdgeBlur` |
| Auto dismiss | `autoDismissEnabled`, `autoDismissIndicator` (`.ring` / `.bar` / `.none`), `indicatorColor`, `indicatorLineWidth` |
| Interaction | `swipeBehavior` (`.button` / `.direct` / `.disabled`), `swipeSymbol`, `swipeTint`, `allowsFullSwipe` |
| Animation | `animation`, `insertion`, `removal` |

### Fonts

```swift
.toastStyle { $0.titleFont = .system(size: 17, weight: .semibold) }
.toastStyle { $0.fontDesign = .rounded; $0.titleWeight = .bold }
.toastStyle { $0.setFont("Avenir Next") }   // custom font, scales with Dynamic Type
```

### Swipe: button or direct

```swift
.toastStyle { $0.swipeBehavior = .direct }   // swipe away to remove, no button
.toastStyle { $0.swipeBehavior = .button }   // default: swipe reveals a button
```

### Auto dismiss

Set it per toast; `nil` keeps the toast until the user dismisses it. A countdown ring (or bar) animates while it waits.

```swift
toasts.show(.warning("Low battery", autoDismiss: 6))     // hides after 6s
toasts.show(.info("Update available", autoDismiss: nil)) // stays
toasts.show(Toast(title: "Custom", autoDismissInterval: 2))

.toastStyle { $0.autoDismissIndicator = .bar }   // or .none
.toastStyle { $0.autoDismissEnabled = false }    // turn auto dismiss off everywhere
```

Built-in presets: `.success`, `.error`, `.warning`, `.info` (each takes a custom `tint`).

## Demo

Open `Examples/SToasts.xcodeproj`.
