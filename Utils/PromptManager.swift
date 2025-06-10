import Foundation

class PromptManager {
    static let shared = PromptManager()
    
    private let prompts = [
        "What's one thing you're grateful for today?",
        "What's a challenge you overcame today?",
        "What's one thing you learned about yourself today?",
        "What's a goal you want to achieve this week?",
        "What's something that made you smile today?",
        "What's a habit you want to improve?",
        "What's one thing you're proud of today?",
        "What's a lesson you learned from a mistake today?",
        "What's something you're looking forward to?",
        "What's a small win you had today?"
    ]
    
    private init() {}
    
    func getPromptForWeek() -> String {
        let calendar = Calendar.current
        let weekNumber = calendar.component(.weekOfYear, from: Date())
        return prompts[weekNumber % prompts.count]
    }
}
