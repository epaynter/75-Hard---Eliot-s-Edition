import Foundation
import HealthKit
import SwiftUI

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    @Published var isHealthKitAvailable = false
    @Published var hasHealthKitPermission = false
    @Published var lastSleepHours: Double = 0.0
    @Published var lastSleepDate: Date?
    
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    private init() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestHealthKitPermission() async {
        guard isHealthKitAvailable else { return }
        
        let typesToRead: Set<HKObjectType> = [sleepType]
        let typesToWrite: Set<HKSampleType> = [sleepType]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            await MainActor.run {
                hasHealthKitPermission = true
            }
        } catch {
            print("❌ HealthKit authorization error: \(error)")
            await MainActor.run {
                hasHealthKitPermission = false
            }
        }
    }
    
    func fetchSleepData(for date: Date) async -> Double? {
        guard hasHealthKitPermission else { return nil }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .hour, value: -12, to: startOfDay),
            end: endOfDay,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                
                if let error = error {
                    print("❌ Sleep data fetch error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Calculate total sleep duration
                var totalSleepMinutes: Double = 0
                
                for sample in sleepSamples {
                    // Only count "asleep" states (not in bed but awake)
                    if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                        
                        let duration = sample.endDate.timeIntervalSince(sample.startDate)
                        totalSleepMinutes += duration / 60.0
                    }
                }
                
                let sleepHours = totalSleepMinutes / 60.0
                
                DispatchQueue.main.async {
                    self.lastSleepHours = sleepHours
                    self.lastSleepDate = date
                }
                
                continuation.resume(returning: sleepHours)
            }
            
            healthStore.execute(query)
        }
    }
    
    func saveSleepData(hours: Double, for date: Date) async -> Bool {
        guard hasHealthKitPermission else { return false }
        
        let startOfSleep = Calendar.current.date(byAdding: .hour, value: -Int(hours), to: Calendar.current.startOfDay(for: date.addingTimeInterval(86400)))!
        let endOfSleep = Calendar.current.startOfDay(for: date.addingTimeInterval(86400))
        
        let sleepSample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: startOfSleep,
            end: endOfSleep
        )
        
        return await withCheckedContinuation { continuation in
            healthStore.save(sleepSample) { success, error in
                if let error = error {
                    print("❌ Sleep data save error: \(error)")
                }
                continuation.resume(returning: success)
            }
        }
    }
    
    func getSleepStatusForDate(_ date: Date) async -> SleepStatus {
        if let sleepHours = await fetchSleepData(for: date) {
            return SleepStatus(
                hours: sleepHours,
                isFromHealthKit: true,
                goalMet: sleepHours >= 7.0
            )
        }
        return SleepStatus(hours: 0, isFromHealthKit: false, goalMet: false)
    }
}

struct SleepStatus {
    let hours: Double
    let isFromHealthKit: Bool
    let goalMet: Bool
    
    var displayText: String {
        let hoursText = String(format: "%.1f", hours)
        let source = isFromHealthKit ? "HealthKit" : "Manual"
        return "\(hoursText)h (\(source))"
    }
} 