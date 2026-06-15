import SwiftUI

// MARK: - Adaptive surfaces

/// Plain sidebar surface matching the Codex app: solid, quiet, and readable.
struct SidebarSurface: ViewModifier {
    func body(content: Content) -> some View {
        content.background(Color.windowBackground)
    }
}

/// Raised card surface: solid system surface, light hairline border, minimal shadow.
/// Flat style matching Claude Code desktop — cards feel integrated, not floating.
struct PlainCardSurface: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .background(Color.cardSurface.opacity(0.18))
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                .clipShape(.rect(cornerRadius: cornerRadius))
        } else {
            fallback(content)
        }
        #else
        fallback(content)
        #endif
    }

    private func fallback(_ content: Content) -> some View {
        content
            .background(Color.cardSurface)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.hairline, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.01), radius: 1, y: 1)
    }
}

extension View {
    func sidebarSurface() -> some View {
        modifier(SidebarSurface())
    }

    func plainCardSurface(cornerRadius: CGFloat) -> some View {
        modifier(PlainCardSurface(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    func iOSGlassIconSurface() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .circle)
        } else {
            self.background(Color.primary.opacity(0.06), in: Circle())
        }
        #else
        self
        #endif
    }

    @ViewBuilder
    func iOSGlassControlSurface(cornerRadius: CGFloat) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(Color.primary.opacity(0.06), in: .rect(cornerRadius: cornerRadius))
        }
        #else
        self
        #endif
    }

    /// Capsule glass for chips, preset pills, meta bars, and selected sidebar
    /// rows — the small interactive elements that should blend with siblings.
    /// `interactive` should be true only for tappable elements.
    @ViewBuilder
    func iOSGlassCapsule(interactive: Bool = false) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.interactive(), in: .capsule)
            } else {
                self.glassEffect(.regular, in: .capsule)
            }
        } else {
            self.background(Color.primary.opacity(0.06), in: Capsule())
        }
        #else
        self
        #endif
    }

    /// Large drawer surface: regular glass filling the trailing-rounded shape
    /// the sidebar drawer clips to. Glass picks up the scaled content card it
    /// floats over — the signature Liquid Glass effect.
    @ViewBuilder
    func iOSGlassDrawerSurface() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(bottomTrailingRadius: 28, topTrailingRadius: 28, style: .continuous))
        } else {
            self.background(Color.windowBackground)
        }
        #else
        self.background(Color.windowBackground)
        #endif
    }

    /// Tinted prominent glass for hero / CTA cards. The tint suggests
    /// prominence without a flat fill; pass `.accentCoral.opacity(0.12)` for
    /// user bubbles, `.red.opacity(0.15)` for errors, etc.
    @ViewBuilder
    func iOSGlassProminentSurface(cornerRadius: CGFloat, tint: Color) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(tint.opacity(0.5), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
        #else
        self.background(tint.opacity(0.5), in: RoundedRectangle(cornerRadius: cornerRadius))
        #endif
    }

    /// Message-bubble glass. Assistant rows use the plain variant (no tint);
    /// user rows pass a soft accent tint to distinguish sides. Notice cards
    /// pass a status tint (orange / red). Falls back to the exact solid fills
    /// the bubbles used before this refactor.
    @ViewBuilder
    func iOSGlassBubble(cornerRadius: CGFloat, tint: Color? = nil) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            if let tint {
                self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            let fallback = tint ?? Color.primary.opacity(0.02)
            self.background(fallback, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
        #else
        // macOS bubbles stay solid — glass is iOS-only by design.
        self
        #endif
    }

    /// Wraps the view in a `GlassEffectContainer` on iOS 26+ so co-located
    /// glass elements blend; passthrough everywhere else. Replaces the verbose
    /// `if #available` boilerplate repeated across the app.
    @ViewBuilder
    func glassEffectContainer(spacing: CGFloat = 8) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { self }
        } else {
            self
        }
        #else
        self
        #endif
    }

    /// Liquid Glass button styling on iOS 26+, falling back to standard
    /// bordered styles elsewhere (and on macOS). `prominent` maps to
    /// `.glassProminent` / `.borderedProminent`.
    @ViewBuilder
    func liquidGlassButton(prominent: Bool = false) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
        #else
        if prominent {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
        #endif
    }
}
