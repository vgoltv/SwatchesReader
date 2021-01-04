//
//  SwatchesContentView.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//



import SwiftUI
import Foundation
import os.log

struct SwatchesContentView: View {
    @Binding var document: SwatchesDocument

    @State var filename = "string"
    
    @ObservedObject var userSettings = UserSettings()
    
    @State var listLayout: [GridItem] = [ GridItem(.flexible()) ]
    @State var gridLayout: [GridItem] = [ GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()) ]
    
    var body: some View {
        VStack {
            
            Logger.viewCycle.logDebugInView("display palette")
            
            
            Spacer()
            
            ScrollView {
                let swatchesCollection: SwatchesCollection = document.collection()
                
                if (swatchesCollection.collectionName().count > 0) {
                    Text( swatchesCollection.collectionName() )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
                
                let layout: [GridItem] = self.userSettings.squareGrid ? self.gridLayout : self.listLayout
                
                LazyVGrid(columns: layout, alignment: .center, spacing: 10) {
                    
                    let swatchesGroups: [SwatchesGroup] = swatchesCollection.groups()
                    let swatchesGroup: SwatchesGroup = swatchesGroups[0]
                    let swatches: [Swatch] = swatchesGroup.swatches()

                    ForEach(0..<swatches.count) { index in
                        let swatch: Swatch = swatches[index]
                        SwatchesCell(title:swatch.baseColorName(), subtitle: swatch.baseColorString()+" | "+swatch.hexString(), color:swatch.baseColor(), gridLayout: self.userSettings.squareGrid)
                    }
                }
                .padding(.all, 10)
            }
            Spacer()
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarItems(trailing:
                                HStack {
                                    Button(action: {
                                        self.userSettings.squareGrid.toggle()
                                    }) {
                                        Image( systemName: self.userSettings.squareGrid ? "square.split.2x2.fill" : "list.dash" )
                                    }
                                }
        )
        .navigationBarTitle(filename)
        .animation(.easeInOut(duration: 0.5))
        .sheet(isPresented: $userSettings.showWelcomeScreen) {
            WelcomeScreen(showWelcomeScreen: $userSettings.showWelcomeScreen, appName:UserSettings.appDisplayName, appVersion:" v."+userSettings.currentVersion)
        }
        .onAppear(perform: bodyAppears)
        .onDisappear(perform: bodyDisappeared)
    }
    
    private func bodyAppears() {
        
    }
    
    private func bodyDisappeared() {
        
    }
    
}

class UserSettings: ObservableObject {
    @Published var currentVersion: String = "1.0"
    
    @Published var showWelcomeScreen: Bool {
        didSet {
            UserDefaults.standard.set(false, forKey: self.keyBaseName + self.keyShowWelcomeName + self.currentVersion)
        }
    }
    
    @Published var squareGrid: Bool {
        didSet {
            UserDefaults.standard.set(self.squareGrid, forKey: self.keyBaseName + self.keyTypeGridName)
        }
    }
    
    @State private var keyBaseName: String
    @State private var keyShowWelcomeName: String
    @State private var keyTypeGridName: String
    
    init() {
        
        let keyBaseStr: String = "swatches_reader_content_"
        self.keyBaseName = keyBaseStr
        
        let keyShowWelcomeStr: String = "show_welcome_screen_"
        self.keyShowWelcomeName = keyShowWelcomeStr
        
        let keyTypeGridStr: String = "square_grid"
        self.keyTypeGridName = keyTypeGridStr
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        
        if let vers = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String {
            self.currentVersion = vers
            self.showWelcomeScreen = UserDefaults.standard.object(forKey: keyBaseStr + keyShowWelcomeStr + vers) as? Bool ?? true
        }else{
            self.currentVersion = "1.0"
            self.showWelcomeScreen = false
            Logger.viewCycle.error("Expected to find a bundle version in the info dictionary")
        }
        
        self.squareGrid = UserDefaults.standard.object(forKey: keyBaseStr + keyTypeGridStr) as? Bool ?? true
        
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

