//
//  PaletteDocument.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 10/26/20.
//  Copyright © 2020 Viktor Goltvyanytsya. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import os.log
import Foundation

/*
 
 How to get UTI:
 
 mdls -name kMDItemContentType -name kMDItemContentTypeTree -name kMDItemKind Crayola.gpl

*/

struct SwatchesDocument {
    let config: ReadConfiguration
    let input: String
    private var unsafeCharacters: CharacterSet
    private var swatchesCollection: SwatchesCollection
    
    public func collection() -> SwatchesCollection {
        return swatchesCollection
    }
}

extension SwatchesDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType(importedAs:"org.gimp.gpl")] }
    static var writableContentTypes: [UTType] { [] }
    
    init(configuration: ReadConfiguration) throws {
        self.config = configuration
        
        var unsafeCharactersMut = NSMutableCharacterSet.illegalCharacters
        unsafeCharactersMut.formUnion(NSCharacterSet.controlCharacters)
        unsafeCharactersMut.formUnion(NSCharacterSet.whitespacesAndNewlines)
        unsafeCharactersMut.formUnion(NSCharacterSet.nonBaseCharacters)
        self.unsafeCharacters = unsafeCharactersMut
        
        
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw SwatchesDocumentError("Unable to load swatches")
        }
        input = string
        
        var paletteName: String?
        
        var isHeaderFound: Bool = false
        
        var isChannelsFieldFound: Bool = false
        var isRGBA: Bool = false
        
        var isColumnsFieldFound: Bool = false
        
        var foundColors: Int = 0
        
        var group: SwatchesGroup = SwatchesGroup(groupName:"", swatches:[] )
        let ungrouped: SwatchesGroup = SwatchesGroup(groupName:"", swatches:[] )
        
        let lines:[Substring] = string.split(whereSeparator: \.isNewline)
        for line in lines {
            let lineStr = String(line)
            if (lineStr.count>0) && !(lineStr.characterIndex(of: "#", direction: .first)==0)  {
                
                if(!isHeaderFound && !(lineStr.elementsEqual("GIMP Palette")) ) {
                    break
                }
                else if( !isHeaderFound ){
                    isHeaderFound = true
                    continue
                }
                
                if (foundColors==0) && (paletteName==nil) && lineStr[0..<5].elementsEqual("Name:")  {
                    paletteName = lineStr[5...].trimmingCharacters(in: self.unsafeCharacters)
                    continue
                }
                
                if (foundColors==0) && !isColumnsFieldFound && lineStr[0..<8].elementsEqual("Columns:") {
                    isColumnsFieldFound = true
                    continue
                }
                
                if (foundColors==0) && !isChannelsFieldFound && lineStr[0..<9].elementsEqual("Channels:") {
                    isChannelsFieldFound = true
                    let channelsStr = lineStr[9...].trimmingCharacters(in: self.unsafeCharacters)
                    isRGBA = channelsStr.elementsEqual("RGBA")
                    if !isRGBA {
                        Logger.vlog.error("Unsupported color space")
                        break
                    }
                    continue
                }
                
                var componentsArr:[Substring] = lineStr.split(whereSeparator: \.isWhitespace)
                if ( componentsArr.count == 0 ) {
                    Logger.vlog.error("Not a color, skipped")
                    continue
                }
                componentsArr = componentsArr.filter({ $0 != ""})
                
                if( componentsArr.count < 3 ) {
                    Logger.vlog.error("Not a color, skipped")
                    continue
                }
                
                let rStr = componentsArr[0]
                let r: Int = Int(rStr)!
                if( r<0 || r>255) {
                    Logger.vlog.error("Value of the red component %li is wrong, color skipped \(r) ")
                    continue
                }
                
                let gStr = componentsArr[1]
                let g: Int = Int(gStr)!
                if( g<0 || g>255) {
                    Logger.vlog.error("Value of the green component %li is wrong, color skipped \(g) ")
                    continue
                }
                
                let bStr = componentsArr[2]
                let b: Int = Int(bStr)!
                if( b<0 || b>255) {
                    Logger.vlog.error("Value of the blue component %li is wrong, color skipped \(b) ")
                    continue
                }
                
                let divider: CGFloat = 255.0
                let color: UIColor = UIColor(red: CGFloat(r)/divider, green: CGFloat(g)/divider, blue: CGFloat(b)/divider, alpha: 1.0)
                
                let totalComponents: Int = componentsArr.count
                var startIndex: UInt = 3
                if isRGBA {
                    startIndex = 4
                }
                
                var swatchName: String = ""
                
                for i in 0..<totalComponents {
                    if(i>=startIndex) {
                        let str: Substring = componentsArr[i]
                        swatchName = swatchName + str
                    }
                }
                
                let swatch = Swatch(colorName:swatchName, color:color )
                group.addSwatch(swatch:swatch)
                if(paletteName != nil) {
                    group.setName(groupName:paletteName!)
                }
                
                foundColors = foundColors + 1
            }
        }
        
        if(paletteName == nil) {
            paletteName = ""
        }
        
        let collection = SwatchesCollection(collectionName:paletteName!, groups:[group], ungrouped:ungrouped)
        self.swatchesCollection = collection
        Logger.vlog.debug("\(collection)")
        

    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = input.data(using: .utf8) else {
            throw SwatchesDocumentError("Unable to save swatches")
        }
        return FileWrapper(regularFileWithContents: data)
    }
}

