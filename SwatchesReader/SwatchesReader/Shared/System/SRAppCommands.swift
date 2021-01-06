//
//  SRAppCommands.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 03.01.2021.
//

import SwiftUI

struct SRAppCommands: Commands {
    @Environment(\.openURL) var openURL: OpenURLAction
    
    @CommandsBuilder var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("SwatchesReader Help") {
                help()
            }
        }
        CommandGroup(replacing: .saveItem) {
            
        }
        CommandGroup(replacing: .systemServices) {
            
        }
    }
    
    func help() {
        
        let string: String = "https://lineengraver.com/swatchesreader"
        // https://lineengraver.com/swatchesreader_app_policy
        
        guard let url: URL = URL(string: string) else {
            return
        }
        
        openURL(url)
    }
    
}
