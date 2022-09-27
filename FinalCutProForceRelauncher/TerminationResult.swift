//
//  TerminationResult.swift
//  FinalCutProForceRelauncher
//  
//  Created by Tomohiro Kumagai on 2022/09/27
//  
//

enum TerminationResult {
    
    case terminateCompletely
    case requestTimedOut
    case requestNotAccepted
}

extension TerminationResult {
    
    var completed: Bool {
        
        switch self {
            
        case .terminateCompletely:
            return true
            
        case .requestTimedOut, .requestNotAccepted:
            return false
        }
    }
}

extension TerminationResult : CustomStringConvertible {
    
    var description: String {
        
        switch self {
            
        case .terminateCompletely:
            return "Pocesses have been terminated completely."
            
        case .requestNotAccepted:
            return "Process termination requests were not be accepted."
            
        case .requestTimedOut:
            return "Processes were not terminated within the prescribed time."
        }
    }
}
