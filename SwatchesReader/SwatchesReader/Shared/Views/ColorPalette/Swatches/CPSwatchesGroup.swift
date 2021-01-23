//
//  CPSwatchesGroup.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 02.01.2021.
//








import Foundation
import SwiftUI
import os.log


public struct CPSwatchesGroup: Identifiable {
    public var id = UUID()
    private var gName: String = ""
    private var gSwatches: [CPSwatch] = []
    
    public init(groupName: String, swatches:[CPSwatch] ) {
        self.gName = groupName
        self.gSwatches.append(contentsOf: swatches)
    }
    
    public func groupName() -> String {
        return gName
    }
    
    public func swatches() -> [CPSwatch] {
        return gSwatches
    }
    
    public func count() -> Int {
        return gSwatches.count
    }
    
    public func getSwatchAt(index:Int) -> (Bool, CPSwatch) {
        if (gSwatches.count > index) {
            return (true, gSwatches[index])
        }
        
        let color: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let swatch = CPSwatch(colorName:"", color:color )
        
        return (false, swatch )
    }
    
    public mutating func addSwatch(swatch: CPSwatch) {
        self.gSwatches.append(swatch)
    }
    
    public mutating func setName(groupName: String) {
        self.gName = groupName
    }
    
}
