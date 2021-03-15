//
//  CPPaletteContentView.swift
//  ColorPalette
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//



import SwiftUI
import Foundation
import os.log

enum UISizeType: UInt {
    case UISizeTypeVertical, UISizeTypeCompact, UISizeTypeHorizontal, UISizeTypeRegular
}


struct CPPaletteContentView: View {
    
    @EnvironmentObject var appModel: SRAppModel
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    let document: CPPaletteDocument
    
    @State var filename: String = ""
    
    @ObservedObject var paletteDataModel: CPPaletteModel = CPPaletteModel()
    

    
    
    
    @State var listLayout: [GridItem] = [ GridItem(.flexible()) ]
    @State var gridLayout: [GridItem] = Array(repeating: .init(.adaptive(minimum: 70)), count: 3)
    
    
    var body: some View {
        
        Group {
            
            Logger.vlog.logDebugInView("display palette")
            
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                VStack {
                    paletteView
                    Spacer()
                    Divider().background(Color(UIColor.separator)).frame(height: 0.5)
                    
                    if(!paletteDataModel.selectedCellUndefined)
                    {
                        let palette: CPSwatchesPalette = document.swatchesPalette()
                        let swatchesGroups: [CPSwatchesGroup] = palette.groups()
                        let swatchesGroup: CPSwatchesGroup = swatchesGroups[0]
                        let swatches: [CPSwatch] = swatchesGroup.swatches()
                        let swatch: CPSwatch = swatches[paletteDataModel.selectedCellIndexPath.row]
                        
                        CPColorPickerView( pickerColor:$paletteDataModel.pickerColor,
                                           sizeType:UISizeType.UISizeTypeHorizontal,
                                          startColor: swatch.baseColor() )
                            .padding()
                            .frame(height: 90)
                    }else{
                        CPColorPickerView( pickerColor:$paletteDataModel.pickerColor,
                                           sizeType:UISizeType.UISizeTypeHorizontal,
                                          startColor: Color.gray )
                            .padding()
                            .frame(height: 90)
                    }
                    
                }
                //.edgesIgnoringSafeArea(.all)
            } else if verticalSizeClass == .regular && horizontalSizeClass == .regular {
                HStack {
                    paletteView
                    Divider().background(Color(UIColor.separator)).frame(width: 0.5)
                    if(!paletteDataModel.selectedCellUndefined)
                    {
                        let palette: CPSwatchesPalette = document.swatchesPalette()
                        let swatchesGroups: [CPSwatchesGroup] = palette.groups()
                        let swatchesGroup: CPSwatchesGroup = swatchesGroups[0]
                        let swatches: [CPSwatch] = swatchesGroup.swatches()
                        let swatch: CPSwatch = swatches[paletteDataModel.selectedCellIndexPath.row]
                        let startColor: Color = swatch.baseColor()
                        
                        CPColorPickerView( pickerColor:$paletteDataModel.pickerColor,
                                           sizeType:UISizeType.UISizeTypeRegular,
                                          startColor: startColor )
                            .frame(width: 200)
                    }else{
                        let startColor: Color = Color.gray
                        
                        CPColorPickerView( pickerColor:$paletteDataModel.pickerColor,
                                           sizeType:UISizeType.UISizeTypeRegular,
                                          startColor: startColor )
                            .frame(width: 200)
                    }
                }
                //.edgesIgnoringSafeArea(.all)
            }else{
                paletteView
            }
            
        }

    }
    
    var paletteView: some View {
        VStack {
            Spacer()
            
            ScrollView {
                let palette: CPSwatchesPalette = document.swatchesPalette()

                let paletteName: String = palette.name()
                if( paletteName.count > 0 ) {
                    Group {
                        Text( paletteName )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .font(Font.system(.headline, design: .rounded).bold())
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                    Divider().background(Color(UIColor.separator)).frame(height: 0.5)
                }
                
                let layout: [GridItem] = self.paletteDataModel.viewSwatchesOption == 0 ? self.listLayout : self.gridLayout
                
                LazyVGrid(columns: layout, alignment: .center, spacing: 10) {
                    
                    let swatchesGroups: [CPSwatchesGroup] = palette.groups()
                    let swatchesGroup: CPSwatchesGroup = swatchesGroups[0]
                    let swatches: [CPSwatch] = swatchesGroup.swatches()
                    
                    ForEach(0..<swatches.count) { index in
                        let swatch: CPSwatch = swatches[index]
                        let ip: IndexPath = IndexPath(row:index, section:0)
                        
                        CPPaletteColorItemCell(
                            selectedCellIndexPath: $paletteDataModel.selectedCellIndexPath,
                            pickerColor:$paletteDataModel.pickerColor,
                            indexPath:ip,
                            swatch:swatch,
                            viewOption: self.paletteDataModel.viewSwatchesOption )
                    }
                }
                .padding(.all, 10)
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarItems(trailing:
                                
                                Menu {
                                    Picker(selection: $paletteDataModel.viewSwatchesOption, label: Text("Swatches")) {
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
                                        Image( systemName: self.paletteDataModel.viewSwatchesOption == 0 ? "list.dash" : "square.grid.2x2" )
                                            .frame(width: 48 , height: 48, alignment: .center)
                                    })
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .menuStyle(BorderlessButtonMenuStyle())
        )
        .navigationBarTitle(filename)
        .animation(.easeInOut(duration: 0.5))
        .sheet(isPresented: $appModel.showWelcomeScreen) {
            WelcomeScreen(showWelcomeScreen: $appModel.showWelcomeScreen, appName:SRAppModel.appDisplayName, appVersion:" v."+appModel.currentVersion)
        }
        .onAppear(perform: bodyAppears)
        .onDisappear(perform: bodyDisappeared)
    }
    
    private func bodyAppears() {
        // Not implemented yet
    }
    
    private func bodyDisappeared() {
        // Not implemented yet
    }
    
}

