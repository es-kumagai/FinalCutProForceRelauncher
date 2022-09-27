//
//  Main.swift
//  FinalCutProForceRelauncher
//  
//  Created by Tomohiro Kumagai on 2022/09/25
//  
//

import AppKit

let result = try await FinalCutPro.terminate()
NSLog(result.description)

try await FinalCutPro.open()
NSLog("A process of Final Cut Pro has been relaunched.")
