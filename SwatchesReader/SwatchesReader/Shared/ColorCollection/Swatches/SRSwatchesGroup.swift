//
//  SRSwatchesGroup.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 02.01.2021.
//








import Foundation
import SwiftUI
import os.log


public struct SRSwatchesGroup {
    
    private var gName: String = ""
    private var gSwatches: [SRSwatch] = []
    
    public init(groupName: String, swatches:[SRSwatch] ) {
        self.gName = groupName
        self.gSwatches.append(contentsOf: swatches)
    }
    
    public func groupName() -> String {
        return gName
    }
    
    public func swatches() -> [SRSwatch] {
        return gSwatches
    }
    
    public func count() -> Int {
        return gSwatches.count
    }
    
    public func getSwatchAt(index:Int) -> (Bool, SRSwatch) {
        if (gSwatches.count > index) {
            return (true, gSwatches[index])
        }
        
        let color: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let swatch = SRSwatch(colorName:"", color:color )
        
        return (false, swatch )
    }
    
    public mutating func addSwatch(swatch: SRSwatch) {
        self.gSwatches.append(swatch)
    }
    
    public mutating func setName(groupName: String) {
        self.gName = groupName
    }
    
}
