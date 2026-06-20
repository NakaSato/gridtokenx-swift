//
//  Inject.swift
//  gridtokexios
//
//  Minimal hot-reload shim (no SPM dependency). In DEBUG it listens for
//  InjectionIII's bundle-reload notification and forces affected views to
//  re-render; in RELEASE every symbol compiles to a no-op and is stripped.
//
//  Setup:
//    1. Install + run InjectionIII.app, point it at this project root.
//    2. Debug build already carries `-Xlinker -interposable` (Other Linker Flags).
//    3. Run from Xcode (⌘R). Save any .swift → injected, views reload ~1s.
//
//  Usage in a View:
//    @ObserveInjection var inject
//    var body: some View { ... .enableInjection() }
//

import SwiftUI
import Combine

/// Declared for the `@ObserveInjection var inject` convention at the top of each
/// view. The redraw is driven entirely by `.enableInjection()` (see below), so
/// this wrapper holds no observer — it's a marker that keeps call sites uniform.
@propertyWrapper
struct ObserveInjection {
    var wrappedValue: Int { 0 }
    init() {}
}

#if DEBUG

/// Singleton that flips a published flag whenever InjectionIII reloads a bundle.
final class InjectionObserver: ObservableObject {
    static let shared = InjectionObserver()
    @Published private(set) var generation = 0
    private var cancellable: AnyCancellable?

    private init() {
        cancellable = NotificationCenter.default
            .publisher(for: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))
            .sink { [weak self] _ in self?.generation &+= 1 }
    }
}

extension View {
    /// Re-evaluates this view's body on every hot reload.
    func enableInjection() -> some View {
        modifier(InjectionModifier())
    }
}

private struct InjectionModifier: ViewModifier {
    @ObservedObject private var observer = InjectionObserver.shared
    func body(content: Content) -> some View {
        // `.id` change on reload forces a fresh body evaluation.
        content.id(observer.generation)
    }
}

#else

extension View {
    @inline(__always) func enableInjection() -> some View { self }
}

#endif
