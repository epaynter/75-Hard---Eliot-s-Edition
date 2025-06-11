//
//  SupplementManager.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import Foundation
import SwiftData

class SupplementManager {
    static let shared = SupplementManager()
    
    private init() {}
    
    func getSupplementsForTime(date: Date) -> [Supplement] {
        // This would typically require a ModelContext to fetch from SwiftData
        // For now, return empty array - this will be properly implemented when called with context
        return []
    }
    
    func getSupplementsForTime(date: Date, context: ModelContext) -> [Supplement] {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        let descriptor = FetchDescriptor<Supplement>(
            predicate: #Predicate { supplement in
                supplement.isActive
            }
        )
        
        do {
            let allSupplements = try context.fetch(descriptor)
            
            return allSupplements.filter { supplement in
                switch supplement.timeOfDay {
                case .morning:
                    return hour < 12 // Morning supplements
                case .evening:
                    return hour >= 17 // Evening supplements (5 PM onwards)
                case .both:
                    return true // Both times - always relevant
                }
            }
        } catch {
            print("Error fetching supplements: \(error)")
            return []
        }
    }
    
    func createDefaultSupplements(context: ModelContext) {
        // Create some default supplements if none exist
        let descriptor = FetchDescriptor<Supplement>()
        
        do {
            let existingSupplements = try context.fetch(descriptor)
            if existingSupplements.isEmpty {
                let defaults = [
                    Supplement(name: "Multivitamin", dosage: "1 capsule", timeOfDay: .morning),
                    Supplement(name: "Omega-3", dosage: "1000mg", timeOfDay: .morning),
                    Supplement(name: "Magnesium", dosage: "400mg", timeOfDay: .evening)
                ]
                
                for supplement in defaults {
                    context.insert(supplement)
                }
                
                try context.save()
            }
        } catch {
            print("Error creating default supplements: \(error)")
        }
    }
}