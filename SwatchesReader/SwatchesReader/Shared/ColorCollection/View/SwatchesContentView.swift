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
    @State var gridLayout: [GridItem] = Array(repeating: .init(.adaptive(minimum: 70)), count: 3)
    
    var body: some View {
        
        VStack {
            
            Logger.vlog.logDebugInView("display palette")
            
            
            Spacer()
            
            ScrollView {
                let swatchesCollection: SwatchesCollection = document.collection()
                let collectionName: String = swatchesCollection.collectionName()
                if( collectionName.count > 0 ) {
                    Group {
                        Text( collectionName )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .font(Font.system(.headline, design: .rounded).bold())
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                    Divider().background(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2)).frame(height: 0.5)
                }
                
                let layout: [GridItem] = self.userSettings.squareGrid ? self.gridLayout : self.listLayout
                
                LazyVGrid(columns: layout, alignment: .center, spacing: 10) {
                    
                    let swatchesGroups: [SwatchesGroup] = swatchesCollection.groups()
                    let swatchesGroup: SwatchesGroup = swatchesGroups[0]
                    let swatches: [Swatch] = swatchesGroup.swatches()

                    ForEach(0..<swatches.count) { index in
                        let swatch: Swatch = swatches[index]
                        SwatchesCell(title:swatch.baseColorName(), subtitle: swatch.baseColorString(), hexStr:swatch.hexString(), descr:swatch.baseColorString(), color:swatch.baseColor(), gridLayout: self.userSettings.squareGrid )
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
                                        Image( systemName: self.userSettings.squareGrid ? "square.grid.2x2" : "list.dash" )
                                            .frame(width: 48 , height: 48, alignment: .center)
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
        
        let infoDictionaryKey = "CFBundleShortVersionString"
        
        if let vers = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String {
            self.currentVersion = vers
            self.showWelcomeScreen = UserDefaults.standard.object(forKey: keyBaseStr + keyShowWelcomeStr + vers) as? Bool ?? true
        }else{
            self.currentVersion = "1.0"
            self.showWelcomeScreen = false
            Logger.vlog.error("Expected to find a bundle version in the info dictionary")
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

