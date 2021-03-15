//
//  SRAppModel.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 09.01.2021.
//

import Foundation
import SwiftUI
import os.log



class SRAppModel: ObservableObject {
    
    @Published var currentVersion: String = "1.0"
    
    @Published var showWelcomeScreen: Bool {
        didSet {
            UserDefaults.standard.set(false, forKey: self.keyBaseName + self.keyShowWelcomeName + self.currentVersion)
        }
    }
    
    @State private var keyBaseName: String
    @State private var keyShowWelcomeName: String
    
    init() {
        
        let keyBaseStr: String = "swatches_reader_content_"
        self.keyBaseName = keyBaseStr
        
        let keyShowWelcomeStr: String = "show_welcome_screen_"
        self.keyShowWelcomeName = keyShowWelcomeStr
        
        let infoDictionaryKey = "CFBundleShortVersionString"
        
        if let vers = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String {
            self.currentVersion = vers
            self.showWelcomeScreen = UserDefaults.standard.object(forKey: keyBaseStr + keyShowWelcomeStr + vers) as? Bool ?? true
        }else{
            self.currentVersion = "1.0"
            self.showWelcomeScreen = false
            Logger.vlog.error("Expected to find a bundle version in the info dictionary")
        }
        
    }
    
    public static var appDisplayName: String {
        if let bundleDisplayName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return bundleDisplayName
        } else if let bundleName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return "SwatchesReader"
    }

    var palettes = [
        Palette(title: "Palette #1", author: "Author #1"),
        Palette(title: "Palette #2", author: "Author #2"),
        Palette(title: "Palette #3", author: "Author #3")
    ]
}

struct Palette: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    
    func updateProgress() -> Void {
        // not implemented yet
    }
    
    func markCompleted() -> Void {
        // not implemented yet
    }
    
}
