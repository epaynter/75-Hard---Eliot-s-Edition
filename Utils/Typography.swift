import SwiftUI

/// Central place to manage the app's font hierarchy so we can tweak sizes & weights in one spot.
public enum Typography {
    /// Large title used for major headings.
    public static let titleLarge: Font = .system(size: 28, weight: .semibold, design: .default)
    
    /// Medium title used for secondary headings.
    public static let titleMedium: Font = .system(size: 20, weight: .medium, design: .default)
    
    /// Standard body text style.
    public static let body: Font = .system(size: 16, weight: .regular, design: .default)
    
    /// Caption / tertiary text.
    public static let caption: Font = .system(size: 13, weight: .regular, design: .default)
}

// Convenience helpers so we can write `.font(.titleLarge)` etc.
public extension Font {
    static let titleLarge = Typography.titleLarge
    static let titleMedium = Typography.titleMedium
    static let bodyText = Typography.body      // Named differently to avoid clashing with existing `.body` static property.
    static let captionText = Typography.caption
} 