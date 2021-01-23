//
//  CPPaletteDocument.swift
//  ColorPalette
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

struct CPPaletteDocument {
    private var palette: CPSwatchesPalette
    
    public func swatchesPalette() -> CPSwatchesPalette {
        return palette
    }
}

extension CPPaletteDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.GPLDocumentType] }
    static var writableContentTypes: [UTType] { [] }
    
    init(colorPalette: CPSwatchesPalette) {
        self.palette = colorPalette
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CPPaletteDocumentError("Unable to load swatches")
        }
        
        let contentType: UTType = configuration.contentType

        
        if( contentType.conforms(to: UTType.GPLDocumentType) ) {
            let fileRep: CPGPLPaletteFileRepresentation = try CPGPLPaletteFileRepresentation(data: data)
            self.palette = fileRep.swatchesPalette()
            
            Logger.vlog.debug("Parsed palette")
        }else{
            self.palette = CPSwatchesPalette.empty
            Logger.vlog.error("Unable to read swatches from UTType: \(contentType)")
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        do {
            let fileRep: CPGPLPaletteFileRepresentation = CPGPLPaletteFileRepresentation(colorPalette: self.palette)
            let fileRepData = try fileRep.data()
            return .init(regularFileWithContents: fileRepData)
        } catch {
            throw CPPaletteDocumentError("Unable to save swatches")
        }
    }
    
    
}

extension UTType {
    static var GPLDocumentType: UTType {
        UTType(importedAs: "org.gimp.gpl")
    }
}
