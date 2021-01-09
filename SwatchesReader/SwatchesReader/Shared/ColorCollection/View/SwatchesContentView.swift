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
    
    @ObservedObject var userSettings = SRUserSettings()
    
    @State private var sort: Int = 0
    

    
    @State var listLayout: [GridItem] = [ GridItem(.flexible()) ]
    @State var gridLayout: [GridItem] = Array(repeating: .init(.adaptive(minimum: 70)), count: 3)
    
    var body: some View {
        
        VStack {
            
            Logger.vlog.logDebugInView("display palette")
            
            
            Spacer()
            
            ScrollView {
                let swatchesCollection: SRSwatchesCollection = document.collection()
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
                    Divider().background(Color(UIColor.separator)).frame(height: 0.5)
                }
                
                let layout: [GridItem] = self.userSettings.viewSwatchesOption == 0 ? self.listLayout : self.gridLayout
                
                LazyVGrid(columns: layout, alignment: .center, spacing: 10) {
                    
                    let swatchesGroups: [SRSwatchesGroup] = swatchesCollection.groups()
                    let swatchesGroup: SRSwatchesGroup = swatchesGroups[0]
                    let swatches: [SRSwatch] = swatchesGroup.swatches()

                    ForEach(0..<swatches.count) { index in
                        let swatch: SRSwatch = swatches[index]
                        let ip: IndexPath = IndexPath(row:index, section:0)
                        SwatchesCell(selectedCellIndexPath: $userSettings.selectedCellIndexPath, indexPath:ip, swatch:swatch, viewOption: self.userSettings.viewSwatchesOption )
                    }
                }
                .padding(.all, 10)
            }
            Spacer()
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarItems(trailing:
                                
                                Menu {
                                    Picker(selection: $userSettings.viewSwatchesOption, label: Text("Swatches")) {
                                        HStack(spacing: 2) {
                                            Text("List")
                                            Image(systemName: "list.dash")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32)
                                        }
                                        .tag(0)
                                        HStack(spacing: 2) {
                                            Text("Icons")
                                            Image(systemName: "square.grid.2x2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32)
                                        }
                                        .tag(1)
                                    }
                                } label: {
                                    Button(action: {
                                        
                                    }, label: {
                                        Image( systemName: self.userSettings.viewSwatchesOption == 0 ? "list.dash" : "square.grid.2x2" )
                                            .frame(width: 48 , height: 48, alignment: .center)
                                    })
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .menuStyle(BorderlessButtonMenuStyle())
        )
        .navigationBarTitle(filename)
        .animation(.easeInOut(duration: 0.5))
        .sheet(isPresented: $userSettings.showWelcomeScreen) {
            WelcomeScreen(showWelcomeScreen: $userSettings.showWelcomeScreen, appName:SRUserSettings.appDisplayName, appVersion:" v."+userSettings.currentVersion)
        }
        .onAppear(perform: bodyAppears)
        .onDisappear(perform: bodyDisappeared)
    }
    
    private func bodyAppears() {
        
    }
    
    private func bodyDisappeared() {
        
    }
    

    
}
