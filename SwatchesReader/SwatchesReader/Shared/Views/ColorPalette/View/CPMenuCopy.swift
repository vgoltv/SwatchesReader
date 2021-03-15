//
//  CPMenuCopy.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 22.01.2021.
//

import Foundation
import SwiftUI


struct CPMenuCopy: View {
    var color: Color
    
    public init( color: Color ) {
        self.color = color
    }
    
    var body: some View {
        let cp: CPColor = CPColor(color: color )
        Button(action: {
            UIPasteboard.general.color = cp.nativeColor
        }) {
            Text("Color")
            Image(systemName: "eyedropper.full")
        }
        
        Button(cp.hexstr, action: { UIPasteboard.general.string = cp.hexstr } )
        Button(cp.rgbstr, action: { UIPasteboard.general.string = cp.rgbstr } )
        Button(cp.cmykstr, action: { UIPasteboard.general.string = cp.cmykstr } )
        Button(cp.hslstr, action: { UIPasteboard.general.string = cp.hslstr } )
        Button(cp.hsvstr, action: { UIPasteboard.general.string = cp.hsvstr } )
        Button(cp.labstr, action: { UIPasteboard.general.string = cp.labstr } )
        Button(cp.whitestr, action: { UIPasteboard.general.string = cp.whitestr } )
        
    }
    
}
