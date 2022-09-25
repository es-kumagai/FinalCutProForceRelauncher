//
//  OSStatus.swift
//  FinalCutProForceRelauncher
//  
//  Created by Tomohiro Kumagai on 2022/09/25
//  
//

import Darwin.C

enum OSStatusError : Error {
    
    case errno(Int32)
}
