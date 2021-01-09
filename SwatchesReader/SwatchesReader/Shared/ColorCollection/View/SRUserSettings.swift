//
//  SRUserSettings.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 08.01.2021.
//

import SwiftUI
import Foundation
import os.log







class SRUserSettings: ObservableObject {
    @Published var currentVersion: String = "1.0"
    
    @Published var showWelcomeScreen: Bool {
        didSet {
            UserDefaults.standard.set(false, forKey: self.keyBaseName + self.keyShowWelcomeName + self.currentVersion)
        }
    }
    
    @Published var viewSwatchesOption: Int {
        didSet {
            UserDefaults.standard.set(self.viewSwatchesOption, forKey: self.keyBaseName + self.keyViewSwatchesOption)
        }
    }
    
    @Published var selectedCellIndexPath: IndexPath {
        didSet {// onSelectedItemAtIndexPath
            
        }
    }
    
    @State private var keyBaseName: String
    @State private var keyShowWelcomeName: String
    @State private var keyViewSwatchesOption: String
    
    init() {
        
        let keyBaseStr: String = "swatches_reader_content_"
        self.keyBaseName = keyBaseStr
        
        let keyShowWelcomeStr: String = "show_welcome_screen_"
        self.keyShowWelcomeName = keyShowWelcomeStr
        
        let keyViewSwatchesOptionStr: String = "view_swatches"
        self.keyViewSwatchesOption = keyViewSwatchesOptionStr
        
        let infoDictionaryKey = "CFBundleShortVersionString"
        
        if let vers = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String {
            self.currentVersion = vers
            self.showWelcomeScreen = UserDefaults.standard.object(forKey: keyBaseStr + keyShowWelcomeStr + vers) as? Bool ?? true
        }else{
            self.currentVersion = "1.0"
            self.showWelcomeScreen = false
            Logger.vlog.error("Expected to find a bundle version in the info dictionary")
        }
        
        self.viewSwatchesOption = UserDefaults.standard.object(forKey: keyBaseStr + keyViewSwatchesOptionStr) as? Int ?? 0
        
        self.selectedCellIndexPath = IndexPath(row: -1, section: -1)
    }
    
    public static var appDisplayName: String {
        if let bundleDisplayName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return bundleDisplayName
        } else if let bundleName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return "SwatchesReader"
    }
}

