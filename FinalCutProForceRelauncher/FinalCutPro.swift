//
//  FinalCutPro.swift
//  FinalCutProForceRelauncher
//  
//  Created by Tomohiro Kumagai on 2022/09/25
//  
//

import AppKit

struct FinalCutPro {
    
    static var workspace = NSWorkspace.shared
    static let bundleIdentifier = "com.apple.FinalCut"
    
    static let checkingInterval: UInt64 = 100_000_000
    static let normalTerminationTimeout: DispatchTime = .now() + 5
    static let forceTerminationTimeout: DispatchTime = .now() + 10

    let runningApplication: NSRunningApplication
}

extension FinalCutPro {

    static var instances: [FinalCutPro] {
        
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).map(FinalCutPro.init)
    }
    
    static var bundleURL: URL {
        
        get throws {
            
            guard let url = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
                
                throw FinalCutProError.applicationIsNotFound
            }
            
            return url
        }
    }

    @discardableResult
    static func open() async throws -> FinalCutPro {
    
        let configuration = NSWorkspace.OpenConfiguration()
        
        NSLog("Launching a Final Cut Pro ...")
        return try await FinalCutPro(runningApplication: workspace.openApplication(at: bundleURL, configuration: configuration))
    }

    @discardableResult
    static func terminate(withCheckingInterval interval: UInt64 = checkingInterval, normalTerminationTimeout: DispatchTime = normalTerminationTimeout, forceTerminationTimeout: DispatchTime = forceTerminationTimeout) async throws -> TerminationResult {
        
        if try await normalTerminate(withCheckingInterval: interval, timeout: normalTerminationTimeout).completed {

            return .terminateCompletely
        }
        else {

            NSLog("Normal termination hasn't be completed")
            return try await forceTerminate(withCheckingInterval: interval, timeout: forceTerminationTimeout)
        }
    }
    
    @discardableResult
    static func forceTerminate(withCheckingInterval interval: UInt64 = checkingInterval, timeout: DispatchTime = forceTerminationTimeout) async throws -> TerminationResult {
        
        guard instances.forceTerminate() else {
            
            NSLog("Failed to request force termination.")
            return .requestNotAccepted
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            
            while !instances.isAllTerminated {
                
                try await Task.sleep(nanoseconds: 100_000_000)
            }
            
            semaphore.signal()
        }
        
        switch semaphore.wait(timeout: timeout) {
            
        case .success:
            return .terminateCompletely
            
        case .timedOut:
            return .requestTimedOut
        }
    }

    @discardableResult
    static func normalTerminate(withCheckingInterval interval: UInt64 = checkingInterval, timeout: DispatchTime = normalTerminationTimeout) async throws -> TerminationResult {
        
        guard instances.normalTerminate() else {
            
            NSLog("Failed to request force termination.")
            return .requestNotAccepted
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            
            while !instances.isAllTerminated {
                
                try await Task.sleep(nanoseconds: 100_000_000)
            }
            
            semaphore.signal()
        }
        
        switch semaphore.wait(timeout: timeout) {
            
        case .success:
            return .terminateCompletely
            
        case .timedOut:
            return .requestTimedOut
        }
    }

    var processIdentifier: pid_t {
        
        runningApplication.processIdentifier
    }
    
    var bundleIdentifier: String {
        
        runningApplication.bundleIdentifier!
    }
    
    var bundleURL: URL {
        
        runningApplication.bundleURL!
    }
    
    var isHangup: Bool {
        
        // TODO: ハングアップしているかを判定する方法がわからないため、実装保留中です。
        // ここでハングアップ判定ができたら、最初は通常の終了を試みようとして、
        // ハングアップしている場合に強制終了を試みることが可能になります。
        return true
    }
    
    func signal(_ signal: some BinaryInteger) throws {
        
        guard kill(processIdentifier, Int32(signal)) == S_OK else {
            
            throw OSStatusError.errno(errno)
        }
    }
    
    @discardableResult
    func forceTerminate() -> Bool {
        
        NSLog("Trying force termination of a Final Cut Pro process (pid = \(processIdentifier)).")
        return runningApplication.forceTerminate()
    }
    
    @discardableResult
    func normalTerminate() -> Bool {
        
        NSLog("Trying normal termination of a Final Cut Pro process (pid = \(processIdentifier)).")
        return runningApplication.terminate()
    }
}

extension Array<FinalCutPro> {
    
    @discardableResult
    func forceTerminate() -> Bool {
        
        reduce(true) { result, finalCutPro in
            
            result && finalCutPro.forceTerminate()
        }
    }
    
    @discardableResult
    func normalTerminate() -> Bool {
        
        reduce(true) { result, finalCutPro in
            
            guard !finalCutPro.isHangup else {
                
                return false
            }
            
            return result && finalCutPro.normalTerminate()
        }
    }
    
    var isAllTerminated: Bool {
        
        guard !isEmpty else {
            
            return true
        }
        
        return allSatisfy { $0.runningApplication.isTerminated }
    }
}
