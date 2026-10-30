//
//  StackedToasts.swift
//  SToasts
//
//  Created by SRH on 30/10/26.
//

import SwiftUI

//Toast Model
struct Toast: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var symbol: String
    var title: String
    var description: String
    var tintColor: Color
    /// Automatic dismiss after the given time (In Seconds)
    var autoDismissInterval: Double? = nil
}

struct StackedToasts: View {
    var glassTintOpacity: CGFloat = 0
    @Binding var toasts: [Toast]
    var body: some View {
        ///Using  ScrollView with VisualEffect API to create stack  instead of ZSTACK!
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(toasts.reversed()) { toast in
                    let index = toasts.firstIndex(of: toast) ?? 0
                    ToastView(glassTintOpacity: glassTintOpacity, toast: toast) {
                        toasts.removeAll(where: { $0.id == toast.id })
                    }
                    .visualEffect({ content, proxy in
                        let minY = proxy.frame(in: .scrollView).minY
                        let progress = minY / 65
                        ///Only pushing two toasts!
                        let offset = min(progress * 10, 20)
                        let scale = min(progress * 0.05, 0.1)
                        
                        return content
                            .scaleEffect(1-scale, anchor: .bottom)
                            .offset(y: -minY)
                            .offset(y: offset)
                    })
                    .zIndex(Double(index))
                    .transition(.asymmetric(
                        insertion: .offset(y: 500).combined(with: AnyTransition(.blurReplace)),
                        removal: .move(edge: .leading).combined(with: AnyTransition(.blurReplace))
                    ))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDisabled(true)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .frame(height: 90)
        ///90-65 = 25!
        .offset(y: 25 - max(min(CGFloat(toasts.count - 1) * 12.5, 25), 0))
        .swipeActionsContainer()
        /// OPTIONAL: (Adding Soft blur  background )
        .background {
            ScrollView(.vertical) { }
                .frame(height: 0)
                .allowsHitTesting(false)
                .safeAreaBar(edge: .bottom, spacing: 0) {
                    Text(" ")
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                }
                .scrollEdgeEffectStyle(.soft, for: .bottom)
                .opacity(toasts.isEmpty ? 0 : 1)
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: toasts)
        .padding(.bottom, 1)
    }
}

fileprivate struct ToastView: View {
    var glassTintOpacity: CGFloat
    var toast: Toast
    var onDismiss: () -> ()
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: toast.symbol)
                .font(.title)
                .foregroundStyle(toast.tintColor.gradient)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(toast.title)
                    .font(.callout)
                    .foregroundStyle(Color.primary)
                
                Text(toast.description)
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }
            .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: 310, alignment: .leading)
        .frame(height: 65)
        ///Adding subtle gradient (inspired  from siri bubble effect
        .background {
            let row1 = Array(repeating: toast.tintColor.opacity(0.15), count: 3)
            let row2 = Array(repeating: toast.tintColor.opacity(0.1), count: 3)
            let row3 = Array(repeating: Color.clear, count: 3)
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0, 0] , [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: row1 + row2 + row3
            )
            .clipShape(.capsule)
        }
        .glassEffect(.regular.tint(glassTint), in: .capsule)
        .contentShape(.capsule)
        .compositingGroup()
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 10)
        ///simply Adding SwipeAction  (As its supported on any view from ios 27+)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(action: onDismiss) {
                Image(systemName: "checkmark")
            }
            .tint(toast.tintColor)
        }
        .task {
            guard let autoDismissInterval = toast.autoDismissInterval else { return }
            try? await Task.sleep(for: .seconds(autoDismissInterval))
            if !Task.isCancelled {
                onDismiss()
            }
        }
    }
    
    var glassTint: Color {
        (colorScheme == .dark ? Color.black : Color.white).opacity(glassTintOpacity)
    }
}

#Preview {
    ContentView()
}
