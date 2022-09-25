//
//  Main.swift
//  FinalCutProForceRelauncher
//  
//  Created by Tomohiro Kumagai on 2022/09/25
//  
//

import AppKit

let finalCutPros = FinalCutPro.instances

try finalCutPros.terminate()
usleep(500_000)
try await FinalCutPro.open()
