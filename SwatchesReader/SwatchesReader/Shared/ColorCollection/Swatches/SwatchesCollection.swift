//
//  SwatchesCollection.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 02.01.2021.
//








import Foundation
import SwiftUI
import os.log


public struct SwatchesCollection {
    
    private var cName: String = ""
    private var cGroups: [SwatchesGroup] = []
    private var cUngrouped: SwatchesGroup
    
    public init(collectionName: String, groups:[SwatchesGroup], ungrouped:SwatchesGroup ) {
        self.cName = collectionName
        self.cGroups.append(contentsOf: groups)
        self.cUngrouped = ungrouped
    }
    
    public func collectionName() -> String {
        return cName
    }
    
    public func groups() -> [SwatchesGroup] {
        return cGroups
    }
    
    public func ungrouped() -> SwatchesGroup {
        return cUngrouped
    }
    
}

extension SwatchesCollection: CustomStringConvertible {
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
