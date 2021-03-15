//
//  CPVColorList.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 21.01.2021.
//

import Foundation
import SwiftUI

struct CPVColorList: View {
    var color: Color
    
    public init( color: Color ) {
        self.color = color
    }
    
    var body: some View {
        
        let bp:CPColor = CPColor(color:color)
        
        let sampleMenuItems: [MenuItem] = [
            MenuItem(name: bp.hexstr, label: "Hex", subMenuItems:nil),
            MenuItem(name: bp.rgbstr, label: "RGB", subMenuItems:nil),
            MenuItem(name: bp.cmykstr, label: "CMYK", subMenuItems:nil),
            MenuItem(name: bp.hslstr, label: "HSL", subMenuItems:nil),
            MenuItem(name: bp.hsvstr, label: "HSV", subMenuItems:nil),
            MenuItem(name: bp.labstr, label: "Lab", subMenuItems:nil),
            MenuItem(name: bp.whitestr, label: "White", subMenuItems:nil)
        ]
        
        List {
            ForEach(sampleMenuItems) { item in
                HStack {
                    Image(systemName: "circlebadge")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 8)
                    Text(item.name)
                        .font(.system(.footnote, design: .rounded))
                }
                .listRowInsets(EdgeInsets())
            }
        }
        
    }
    
}

struct MenuItem: Identifiable {
    var id = UUID()
    var name: String
    var label: String
    var subMenuItems: [MenuItem]?
}
