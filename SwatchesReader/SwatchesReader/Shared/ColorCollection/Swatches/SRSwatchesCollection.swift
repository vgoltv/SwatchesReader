//
//  SRSwatchesCollection.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 02.01.2021.
//








import Foundation
import SwiftUI
import os.log


public struct SRSwatchesCollection {
    
    public static var emptyCollection: SRSwatchesCollection =
        SRSwatchesCollection(collectionName:"", groups:[],
                             ungrouped:SRSwatchesGroup(groupName:"", swatches:[] ))
    
    private var cName: String = ""
    private var cGroups: [SRSwatchesGroup] = []
    private var cUngrouped: SRSwatchesGroup
    
    public init(collectionName: String, groups:[SRSwatchesGroup], ungrouped:SRSwatchesGroup ) {
        self.cName = collectionName
        self.cGroups.append(contentsOf: groups)
        self.cUngrouped = ungrouped
    }
    

    
    public func collectionName() -> String {
        return cName
    }
    
    public func groups() -> [SRSwatchesGroup] {
        return cGroups
    }
    
    public func ungrouped() -> SRSwatchesGroup {
        return cUngrouped
    }
    
}

extension SRSwatchesCollection: CustomStringConvertible {
    public var description: String {
        return """
        --- --- ---
        Collection's title: \(cName)
        Total groups count: \(cGroups.count)
        Total ungrouped swatches count: \(cUngrouped.count())
        --- --- ---
        """
    }
}
