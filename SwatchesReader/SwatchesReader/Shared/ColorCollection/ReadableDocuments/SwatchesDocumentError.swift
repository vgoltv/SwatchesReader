//
//  SwatchesDocumentError.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 03.01.2021.
//

import Foundation

struct SwatchesDocumentError: Error {
    let message: String

    public var localizedDescription: String {
        message
    }

    init(_ message: String) {
        self.message = message
    }
}
