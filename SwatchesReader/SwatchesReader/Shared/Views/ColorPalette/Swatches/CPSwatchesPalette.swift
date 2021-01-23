//
//  CPSwatchesPalette.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 02.01.2021.
//








import Foundation
import SwiftUI
import os.log


public struct CPSwatchesPalette: Identifiable {
    public var id = UUID()
    public static var empty: CPSwatchesPalette =
        CPSwatchesPalette(name:"", groups:[],
                             ungrouped:CPSwatchesGroup(groupName:"", swatches:[] ))
    
    private var cName: String = ""
    private var cGroups: [CPSwatchesGroup] = []
    private var cUngrouped: CPSwatchesGroup
    
    public init(name: String, groups:[CPSwatchesGroup], ungrouped:CPSwatchesGroup ) {
        self.cName = name
        self.cGroups.append(contentsOf: groups)
        self.cUngrouped = ungrouped
    }
    

    
    public func name() -> String {
        return cName
    }
    
    public func groups() -> [CPSwatchesGroup] {
        return cGroups
    }
    
    public func ungrouped() -> CPSwatchesGroup {
        return cUngrouped
    }
    
}

extension CPSwatchesPalette: CustomStringConvertible {
    public var description: String {
        return """
        --- --- ---
        Palette's title: \(cName)
        Total groups count: \(cGroups.count)
        Total ungrouped swatches count: \(cUngrouped.count())
        --- --- ---
        """
    }
}
