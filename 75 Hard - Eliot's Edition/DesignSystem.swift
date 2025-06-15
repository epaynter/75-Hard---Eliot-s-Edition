import SwiftUI
import UIKit

// MARK: - Premium Design System for 75 Hard Transformation Journey

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors - Bold & Masculine
        static let primary = Color(red: 0.9, green: 0.3, blue: 0.2) // Intense Red
        static let secondary = Color(red: 0.15, green: 0.15, blue: 0.18) // Dark Steel
        static let accent = Color(red: 1.0, green: 0.6, blue: 0.0) // Victory Gold
        
        // Background Colors - Industrial
        static let backgroundPrimary = Color(red: 0.08, green: 0.08, blue: 0.09) // Deep Black
        static let backgroundSecondary = Color(red: 0.12, green: 0.12, blue: 0.14) // Charcoal
        static let backgroundTertiary = Color(red: 0.18, green: 0.18, blue: 0.20) // Steel Gray
        
        // Text Colors - High Contrast
        static let textPrimary = Color.white
        static let textSecondary = Color(red: 0.85, green: 0.85, blue: 0.87)
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.62)
        
        // Success/Progress Colors
        static let success = Color(red: 0.2, green: 0.8, blue: 0.3)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let danger = Color(red: 0.9, green: 0.2, blue: 0.2)
        
        // Gradients - Dramatic & Powerful
        static let heroGradient = LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.12),
                Color(red: 0.05, green: 0.05, blue: 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let primaryGradient = LinearGradient(
            colors: [primary, Color(red: 0.7, green: 0.2, blue: 0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let successGradient = LinearGradient(
            colors: [success, Color(red: 0.1, green: 0.6, blue: 0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let goldGradient = LinearGradient(
            colors: [accent, Color(red: 0.8, green: 0.4, blue: 0.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography - Bold & Impactful
    struct Typography {
        // Headlines - Maximum Impact
        static let heroTitle = Font.system(size: 48, weight: .black, design: .rounded)
        static let title1 = Font.system(size: 32, weight: .heavy, design: .default)
        static let title2 = Font.system(size: 24, weight: .bold, design: .default)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        
        // Body Text - Strong & Clear
        static let bodyLarge = Font.system(size: 18, weight: .medium, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
        
        // Special Typography
        static let motivational = Font.system(size: 16, weight: .heavy, design: .monospaced)
        static let stats = Font.system(size: 28, weight: .black, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .default)
        
        // Button Typography
        static let buttonPrimary = Font.system(size: 18, weight: .bold, design: .default)
        static let buttonSecondary = Font.system(size: 16, weight: .semibold, design: .default)
    }
    
    // MARK: - Spacing - Consistent Rhythm
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius - Modern & Sharp
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Shadows - Dramatic Depth
    struct Shadows {
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let heavy = Color.black.opacity(0.4)
        
        static let elevation1 = (color: light, radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let elevation2 = (color: medium, radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let elevation3 = (color: heavy, radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }
}

// MARK: - Premium Button Styles

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isDestructive: Bool
    
    init(_ title: String, icon: String? = nil, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isDestructive = isDestructive
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback for premium feel
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            action()
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.buttonPrimary)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isDestructive ? DesignSystem.Colors.danger : DesignSystem.Colors.primary)
                    .shadow(
                        color: isDestructive ? DesignSystem.Colors.danger.opacity(0.4) : DesignSystem.Colors.primary.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .buttonStyle(PowerButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.buttonSecondary)
                    .fontWeight(.semibold)
            }
            .foregroundColor(DesignSystem.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                    )
            )
        }
        .buttonStyle(PowerButtonStyle())
    }
}

// MARK: - Power Button Style with Dramatic Feedback
struct PowerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Premium Cards

struct WarriorCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.3),
                                        DesignSystem.Colors.backgroundTertiary
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: DesignSystem.Shadows.elevation2.color,
                        radius: DesignSystem.Shadows.elevation2.radius,
                        x: DesignSystem.Shadows.elevation2.x,
                        y: DesignSystem.Shadows.elevation2.y
                    )
            )
    }
}

// MARK: - Progress Indicators

struct WarriorProgressBar: View {
    let progress: Double
    let height: CGFloat
    let showPercentage: Bool
    
    init(progress: Double, height: CGFloat = 12, showPercentage: Bool = true) {
        self.progress = progress
        self.height = height
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.accent)
                }
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(DesignSystem.Colors.backgroundTertiary)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(DesignSystem.Colors.primaryGradient)
                    .frame(width: max(0, progress * UIScreen.main.bounds.width * 0.8), height: height)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: max(0, progress * UIScreen.main.bounds.width * 0.8), height: height / 2)
                            .offset(y: -height / 4)
                    )
            }
        }
    }
}

// MARK: - Motivational Messages
struct MotivationalMessages {
    static let dailyIntensity = [
        "NO EXCUSES TODAY",
        "STAY HARD, WARRIOR",
        "DISCIPLINE IS FREEDOM",
        "FORGE YOURSELF",
        "MENTAL TOUGHNESS BUILDS",
        "EARN YOUR VICTORY",
        "DOMINATE THIS DAY",
        "EMBRACE THE GRIND",
        "CHOOSE THE HARD PATH",
        "WARRIOR MINDSET ACTIVATED",
        "PROVE YOUR STRENGTH",
        "RELENTLESS EXECUTION",
        "UNBREAKABLE SPIRIT",
        "CONQUER YOUR LIMITS"
    ]
    
    static let progressCelebration = [
        "UNSTOPPABLE FORCE",
        "WARRIOR STATUS: LOCKED IN",
        "MENTAL FORTRESS BUILT",
        "DISCIPLINE PAYS DIVIDENDS",
        "TRANSFORMATION IN PROGRESS",
        "STRENGTH BUILDS DAILY",
        "VICTORY TASTES SWEET",
        "CHAMPION MINDSET ACTIVE"
    ]
    
    static func getDailyMessage() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return dailyIntensity[dayOfYear % dailyIntensity.count]
    }
    
    static func getProgressMessage(for percentage: Double) -> String {
        if percentage >= 0.8 {
            return progressCelebration.randomElement() ?? "EXCELLENCE ACHIEVED"
        } else if percentage >= 0.5 {
            return "MOMENTUM BUILDING"
        } else {
            return "TIME TO GRIND"
        }
    }
}

// MARK: - Haptic Feedback Manager
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}