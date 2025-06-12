# ⚠️ CRITICAL MEMORY: Xcode Scope Issues in Remote/CLI Environments

## PROBLEM PATTERN RECOGNITION

**If you see this error pattern:**
```
Cannot find 'ClassName' in scope
```

**And the file exists in the filesystem but isn't being found, this is likely an Xcode target membership issue.**

## ROOT CAUSE

Xcode projects use `.xcodeproj` files that maintain explicit lists of which files belong to which compilation targets. When working remotely or via CLI:

1. **File movement doesn't update project configuration**
2. **Files exist but aren't compiled as part of the target**
3. **Import statements alone cannot fix this**

## GUARANTEED SOLUTION STRATEGY

### Option 1: Embed Critical Classes (RECOMMENDED for CLI/Remote)
```swift
// In main app file
import SwiftUI
import RequiredFramework

// MARK: - Critical Utility Class
class CriticalClass {
    // ... implementation
}

@main
struct MyApp: App {
    // ... use CriticalClass here
}
```

### Option 2: Verify Target Membership (Requires Xcode GUI)
- Open project in Xcode
- Select the file in Project Navigator
- Check "Target Membership" in File Inspector
- Ensure main app target is checked

### Option 3: Recreate File in Main Target
- Delete problematic file
- Create new file directly in main app directory
- Ensure it's created as part of the main target

## PREVENTION RULES

1. **🔴 NEVER assume file movement alone fixes scope issues**
2. **🟡 FOR CRITICAL DEPENDENCIES: Embed in main files when working remotely**
3. **🟢 TEST SCOPE IMMEDIATELY after any file restructuring**
4. **🔵 CONSOLIDATE utilities rather than splitting into many files for remote work**

## INDICATORS THIS IS THE PROBLEM

- ✅ File exists in correct location
- ✅ Import statements are present
- ✅ Code looks syntactically correct
- ❌ "Cannot find X in scope" error persists
- ❌ Moving files between directories didn't help

## WHEN TO USE THIS MEMORY

- Working on Xcode projects via CLI/remote environments
- File movement results in scope errors
- Import statements don't resolve the issue
- The missing class/struct definitely exists in the codebase

## SUCCESS CRITERIA

After applying the solution:
- ✅ Build succeeds without scope errors
- ✅ All functionality remains intact
- ✅ No duplicate code warnings
- ✅ Code organization remains clear

## HISTORICAL CONTEXT

This issue occurred with `HealthKitManager` in the 75 Hard project:
- First attempt: Moved file + added imports → FAILED
- Second attempt: Embedded class in app file → SUCCESS

**Remember: In remote Xcode development, compilation context trumps file organization.**