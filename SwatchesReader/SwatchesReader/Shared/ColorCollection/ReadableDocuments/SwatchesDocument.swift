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
    private var swatchesCollection: SRSwatchesCollection
    
    public func collection() -> SRSwatchesCollection {
        return swatchesCollection
    }
}

extension SwatchesDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.GPLDocumentType] }
    static var writableContentTypes: [UTType] { [] }
    
    init(collection: SRSwatchesCollection) {
        self.swatchesCollection = collection
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw SwatchesDocumentError("Unable to load swatches")
        }
        
        let contentType: UTType = configuration.contentType

        
        if( contentType == UTType.GPLDocumentType ) {
            let fileRep: GPLFileRepresentation = try GPLFileRepresentation(data: data)
            self.swatchesCollection = fileRep.collection()
            
            Logger.vlog.debug("Parsed collection")
        }else{
            self.swatchesCollection = SRSwatchesCollection.emptyCollection
            Logger.vlog.error("Unable to read swatches from UTType: \(contentType)")
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        do {
            let fileRep: GPLFileRepresentation = GPLFileRepresentation(collection: self.swatchesCollection)
            let fileRepData = try fileRep.data()
            return .init(regularFileWithContents: fileRepData)
        } catch {
            throw SwatchesDocumentError("Unable to save swatches")
        }
    }
    
    
}

extension UTType {
    static var GPLDocumentType: UTType {
        UTType(importedAs: "org.gimp.gpl")
    }
}
