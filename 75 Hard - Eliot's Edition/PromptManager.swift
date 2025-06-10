//
//  PromptManager.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import Foundation

class PromptManager {
    static let shared = PromptManager()
    
    private let morningPrompts = [
        "What are you most grateful for today?",
        "What's your main focus for today?",
        "How do you want to show up today?",
        "What would make today feel successful?",
        "What energy do you want to bring to today?",
        "What's one thing you're excited about today?",
        "How can you be 1% better today?"
    ]
    
    private let eveningPrompts = [
        "What went well today? What would you do differently?",
        "What did you learn about yourself today?",
        "How did you grow today?",
        "What are you proud of from today?",
        "What challenged you today and how did you handle it?",
        "What moment made you smile today?",
        "How did you honor your commitments today?"
    ]
    
    private init() {}
    
    func getPromptsForDate(_ date: Date) -> (morning: String, evening: String) {
        let calendar = Calendar.current
        let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
        let weekOfYear = calendar.dateComponents([.weekOfYear], from: startOfYear, to: date).weekOfYear ?? 0
        
        let morningIndex = weekOfYear % morningPrompts.count
        let eveningIndex = weekOfYear % eveningPrompts.count
        
        return (
            morning: morningPrompts[morningIndex],
            evening: eveningPrompts[eveningIndex]
        )
    }
}