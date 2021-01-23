//
//  CPGPLPaletteFileRepresentation.swift
//  ColorPalette
//
//  Created by Viktor Goltvyanytsya on 06.01.2021.
//

import Foundation
import SwiftUI
import os.log





struct CPGPLPaletteFileRepresentation: CPPaletteFileRepresentation {
    private var palette: CPSwatchesPalette
    private static var unsafeCharacters: CharacterSet = CPGPLPaletteFileRepresentation.unsafeChars()
    
    var version:String
    var name:String
    
    public func swatchesPalette() -> CPSwatchesPalette {
        return palette
    }
    
    public func data() throws -> Data {
        let input: String = ""
        guard let data = input.data(using: .utf8) else {
            throw CPPaletteDocumentError("Unable to save swatches")
        }
        
        return data
    }
}


extension CPGPLPaletteFileRepresentation {
    
    init(data: Data) throws {
        (version, name) = CPGPLPaletteFileRepresentation.fillHeader(dict: ["version":"1.0", "name":"GPL File"])
        self.palette = CPGPLPaletteFileRepresentation.readFileData(data: data)
    }
    
    init(colorPalette: CPSwatchesPalette) {
        (version, name) = CPGPLPaletteFileRepresentation.fillHeader(dict: ["version":"1.0", "name":"GPL File"])
        self.palette = colorPalette
    }
    
    private static func readFileData(data: Data)->CPSwatchesPalette {
        var paletteName: String?
        
        var isHeaderFound: Bool = false
        
        var isChannelsFieldFound: Bool = false
        var isRGBA: Bool = false
        
        var isColumnsFieldFound: Bool = false
        
        var foundColors: Int = 0
        
        var group: CPSwatchesGroup = CPSwatchesGroup(groupName:"", swatches:[] )
        let ungrouped: CPSwatchesGroup = CPSwatchesGroup(groupName:"", swatches:[] )
        
        let string = String(decoding: data, as: UTF8.self)
        
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
                    paletteName = lineStr[5...].trimmingCharacters(in: CPGPLPaletteFileRepresentation.unsafeCharacters)
                    continue
                }
                
                if (foundColors==0) && !isColumnsFieldFound && lineStr[0..<8].elementsEqual("Columns:") {
                    isColumnsFieldFound = true
                    continue
                }
                
                if (foundColors==0) && !isChannelsFieldFound && lineStr[0..<9].elementsEqual("Channels:") {
                    isChannelsFieldFound = true
                    let channelsStr = lineStr[9...].trimmingCharacters(in: CPGPLPaletteFileRepresentation.unsafeCharacters)
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
                
                let swatch = CPSwatch(colorName:swatchName, color:color )
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
        
        let palette = CPSwatchesPalette(name:paletteName!, groups:[group], ungrouped:ungrouped)
        return palette
    }
    

    
}


