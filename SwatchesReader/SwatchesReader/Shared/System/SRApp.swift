//
//  SRApp.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//


import SwiftUI
import os.log



@main
struct SRApp: App {
    
    @UIApplicationDelegateAdaptor(SRAppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        
        DocumentGroup(viewing: SwatchesDocument.self) { file in
            if let url = file.fileURL {
                let filename = url.deletingPathExtension().lastPathComponent
                SwatchesContentView(document: file.$document, filename: filename)
            } else {
                Text("Select File")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .commands {
            SRAppCommands()
        }
        
    }
    
    
}



