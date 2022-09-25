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
    
    let runningApplication: NSRunningApplication
}

extension FinalCutPro {

    static var instances: [FinalCutPro] {
        
        workspace.runningApplications
            .filter { $0.bundleIdentifier == bundleIdentifier }
            .map(FinalCutPro.init)
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
    
    var processIdentifier: pid_t {
        
        runningApplication.processIdentifier
    }
    
    var bundleIdentifier: String {
        
        runningApplication.bundleIdentifier!
    }
    
    var bundleURL: URL {
        
        runningApplication.bundleURL!
    }
    
    func signal(_ signal: some BinaryInteger) throws {
        
        guard kill(processIdentifier, Int32(signal)) == S_OK else {
            
            throw OSStatusError.errno(errno)
        }
    }
    
    func terminate() throws {
        
        NSLog("Terminating a process of Final Cut Pro (pid = \(processIdentifier).")
        try signal(SIGKILL)
    }
}

extension Sequence where Element == FinalCutPro {
    
    func terminate() throws {
        
        try forEach {
            
            try $0.terminate()
        }
    }
}
