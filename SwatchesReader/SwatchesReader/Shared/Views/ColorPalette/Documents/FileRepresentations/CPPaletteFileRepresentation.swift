//
//  CPPaletteFileRepresentation.swift
//  ColorPalette
//
//  Created by Viktor Goltvyanytsya on 09.01.2021.
//

import Foundation


protocol CPPaletteFileRepresentation {
    
    var version: String { get set }
    var name: String { get set }
    
    init(data: Data) throws
    init(colorPalette: CPSwatchesPalette)

    func swatchesPalette() -> CPSwatchesPalette
    func data() throws -> Data

}


extension CPPaletteFileRepresentation {

    public static func unsafeChars()->CharacterSet {
        var unsafeCharactersMut = NSMutableCharacterSet.illegalCharacters
        unsafeCharactersMut.formUnion(NSCharacterSet.controlCharacters)
        unsafeCharactersMut.formUnion(NSCharacterSet.whitespacesAndNewlines)
        unsafeCharactersMut.formUnion(NSCharacterSet.nonBaseCharacters)
        
        return unsafeCharactersMut
    }
    
    static func fillHeader(dict:Dictionary<String, String>) -> (String, String) {
        var version: String = ""
        var name: String = ""
        if let vers = dict["version"] {
            version = vers
        }
        
        if let nm = dict["name"] {
            name = nm
        }
        
        return (version, name)
    }
}
