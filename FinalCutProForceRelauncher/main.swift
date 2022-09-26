//
//  Main.swift
//  FinalCutProForceRelauncher
//  
//  Created by Tomohiro Kumagai on 2022/09/25
//  
//

import AppKit

let finalCutPros = FinalCutPro.instances
let semaphore = DispatchSemaphore(value: 0)

Task {
    
    try await FinalCutPro.forceTerminate(withCheckingInterval: 100_000_000)
    try await FinalCutPro.open()

    semaphore.signal()
}

switch semaphore.wait(timeout: .now() + 10) {
    
case .success:
    NSLog("A process of Final Cut Pro has been relaunched.")
    
case .timedOut:
    fatalError("Processes of Final Cut Pro were not terminated within the prescribed time.")
}
