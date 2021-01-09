//
//  SwatchesCell.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//

import SwiftUI
import os.log

struct SwatchesCell: View {
    
    @Binding var selectedCellIndexPath: IndexPath
    let indexPath: IndexPath
    let swatch: SRSwatch
    var viewOption: Int
    
    
    var body: some View {
        
        if ( self.viewOption == 0 ) {
            
            Button(action: {
                if( selectedCellIndexPath.row == indexPath.row && selectedCellIndexPath.row == indexPath.row  ){
                    self.selectedCellIndexPath = IndexPath(row: -1, section: -1)
                }else{
                    self.selectedCellIndexPath = indexPath
                }
                
            }, label: {
                ZStack {
                    
                    
                    if( selectedCellIndexPath.row == indexPath.row && selectedCellIndexPath.row == indexPath.row  ){
                        Color(UIColor.secondarySystemBackground).ignoresSafeArea()
                    }else{
                        Color(UIColor.systemBackground).ignoresSafeArea()
                    }
                    
                    HStack(spacing: 2) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(swatch.baseColorName())
                                .lineLimit(1)
                                .font(.subheadline)
                            Text(swatch.hexString())
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            Text(swatch.baseColorString())
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .frame(minWidth: 0,
                               maxWidth: .infinity,
                               minHeight: 0,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                        
                        
                        
                        if( selectedCellIndexPath.row == indexPath.row && selectedCellIndexPath.row == indexPath.row  ){
                            RoundedRectangle(cornerRadius: 3)
                                .addBorder(Color(UIColor.link), width: 5, cornerRadius: 3)
                                .foregroundColor(swatch.baseColor())
                                .frame(width:100, height: 70)
                        }else{
                            RoundedRectangle(cornerRadius: 3)
                                .addBorder(Color(UIColor.opaqueSeparator), width: 0.5, cornerRadius: 3)
                                .foregroundColor(swatch.baseColor())
                                .frame(width:100, height: 70)
                        }
                    }
                    
                }
                
            }).contextMenu {
                Button(action: {
                    UIPasteboard.general.color = swatch.baseUIColor()
                }) {
                    Text("UIColor")
                    Image(systemName: "eyedropper.full")
                }
                
                Button(swatch.hexString(), action: { UIPasteboard.general.string = swatch.hexString() } )
                Button(swatch.baseColorString(), action: { UIPasteboard.general.string = swatch.baseColorString() } )
            }
            
            
            
        }else{
            
            Button(action: {
                if( selectedCellIndexPath.row == indexPath.row && selectedCellIndexPath.row == indexPath.row  ){
                    self.selectedCellIndexPath = IndexPath(row: -1, section: -1)
                }else{
                    self.selectedCellIndexPath = indexPath
                }
            }, label: {
                if( selectedCellIndexPath.row == indexPath.row && selectedCellIndexPath.row == indexPath.row  ){
                    RoundedRectangle(cornerRadius: 3)
                        .addBorder(Color(UIColor.link), width: 5, cornerRadius: 3)
                        .foregroundColor(swatch.baseColor())
                        .frame(height: 70)
                }else{
                    RoundedRectangle(cornerRadius: 3)
                        .addBorder(Color(UIColor.separator), width: 0.5, cornerRadius: 3)
                        .foregroundColor(swatch.baseColor())
                        .frame(height: 70)
                }
                
            }).contextMenu {
                Button(action: {
                    UIPasteboard.general.color = swatch.baseUIColor()
                }) {
                    Text("UIColor")
                    Image(systemName: "eyedropper.full")
                }
                
                Button(swatch.hexString(), action: { UIPasteboard.general.string = swatch.hexString() } )
                Button(swatch.baseColorString(), action: { UIPasteboard.general.string = swatch.baseColorString() } )
            }
        }
        
        if ( self.viewOption == 0 ) {
            Divider().background(Color(UIColor.separator)).frame(height: 0.5)
        }
    }
    
    
    
    
}

