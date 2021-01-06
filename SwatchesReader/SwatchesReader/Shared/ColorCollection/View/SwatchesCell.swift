//
//  SwatchesCell.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//

import SwiftUI
import os.log

struct SwatchesCell: View {

    var title: String
    var subtitle: String
    var hexStr: String
    var descr: String
    var color: Color
    var gridLayout: Bool
    
    /*
     There is a strange warning, I don't know how to fix it for now:
     
    [UIContextMenuInteraction updateVisibleMenuWithBlock:] while no context menu is visible. This won't do anything.
    */
    
    var body: some View {
        
        Menu {
            Button(hexStr, action: { UIPasteboard.general.string = hexStr } )
            Button(descr, action: { UIPasteboard.general.string = descr } )
        } label: {
            Button(action: {
                Logger.vlog.logDebugSimple("action")
                }, label: {

                    HStack(spacing: 2) {
                        if ( !self.gridLayout ) {
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(title)
                                    .lineLimit(1)
                                    .font(.subheadline)
                                Text(hexStr)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                Text(subtitle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                            .frame(minWidth: 0,
                                            maxWidth: .infinity,
                                            minHeight: 0,
                                            maxHeight: .infinity,
                                            alignment: .topLeading)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .addBorder(Color.gray, width: 0.5, cornerRadius: 3)
                                .foregroundColor(self.color)
                                .frame(width:100, height: 70)
                        } else {
                            RoundedRectangle(cornerRadius: 3)
                                .addBorder(Color.gray, width: 0.5, cornerRadius: 3)
                                .foregroundColor(self.color)
                                .frame(height: 70)
                        }
                        
                        
                    }
                    .padding(EdgeInsets(top: 1.0, leading: 0.0, bottom: 5.0, trailing: 0.0))
                    Spacer()
                })
                .buttonStyle(BorderlessButtonStyle())
        }
        .menuStyle(BorderlessButtonMenuStyle())
        
        if ( !self.gridLayout ) {
            Divider().background(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2)).frame(height: 0.5)
        }
    }
    
    
    

}

