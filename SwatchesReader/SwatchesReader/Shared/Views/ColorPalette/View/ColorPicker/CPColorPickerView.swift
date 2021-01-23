//
//  CPColorPickerView.swift
//  ColorPalette
//
//  Created by Viktor Goltvyanytsya on 09.01.2021.
//

import Foundation
import SwiftUI






struct CPColorPickerView: View {
    
    @Binding var pickerColor: Color
    
    var sizeType: UISizeType
    var startColor: Color
    
    var body: some View {
            if( sizeType==UISizeType.UISizeTypeHorizontal ){
                HStack {
                    
                    Spacer()
                    
                    Menu {
                        CPMenuCopy(color:pickerColor)
                    } label: {
                        Button(action: {
                            
                        }, label: {
                            Image( systemName: "doc.on.clipboard.fill")
                                .frame(width: 48 , height: 48, alignment: .center)
                        })
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    
                    Spacer()
                    ColorPicker(
                        pickerColor.hex,
                        selection: $pickerColor,
                        supportsOpacity: false
                    ).frame(width: 120, height: 90)
                    
                    Spacer()
                    Divider().background(Color(UIColor.separator)).frame(width: 0.5)
                    
                    Button(action: {
                        pickerColor = startColor
                    }, label: {
                        colorRectangle
                            .frame(width:100, height: 70)
                    })
                }
            }else{ // Regular or Vertical, ie right side is not compact
                VStack {
                    Button(action: {
                        pickerColor = startColor
                    }, label: {
                        colorRectangle
                            .frame(height: 65)
                    })
                    Divider().background(Color(UIColor.separator)).frame(height: 0.5)
                    
                    HStack{
                        
                        ColorPicker(
                            "",
                            selection: $pickerColor,
                            supportsOpacity: false
                        )
                        .font(.system(.footnote, design: .rounded))
                        .frame(width:70, height: 70, alignment: .center)
                        
                        Menu {
                            CPMenuCopy(color:pickerColor)
                        } label: {
                            Button(action: {
                                
                            }, label: {
                                Image( systemName: "doc.on.clipboard.fill")
                                    .frame(width: 48 , height: 48, alignment: .center)
                            })
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .menuStyle(BorderlessButtonMenuStyle())
                    }

                    CPVColorList(color:pickerColor)
                    Spacer()
                }
            }
    }
    
    var colorRectangle: some View {
        RoundedRectangle(cornerRadius: 3)
            .addBorder(Color(UIColor.opaqueSeparator), width: 0.5, cornerRadius: 3)
            .foregroundColor(startColor)
    }
    
    
}



