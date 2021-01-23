//
//  CPPaletteExtensions.swift
//  ColorPalette
//
//  Created by Viktor Goltvyanytsya on 10/26/20.
//  Copyright © 2020 Viktor Goltvyanytsya. All rights reserved.
//

import Foundation
import SwiftUI
import os.log


extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let vlog = Logger(subsystem: subsystem, category: "vlog")
    
    public func logDebugInView(_ log: String) -> EmptyView {
        Logger.vlog.debug("log:\(log)")
        return EmptyView()
    }
    
    public func logDebugSimple(_ log: String) {
        Logger.vlog.debug("log:\(log)")
    }
}

extension View {
    @ViewBuilder func visible(_ shouldVisible: Bool) -> some View {
        switch shouldVisible {
        case true: self
        case false: self.hidden()
        }
    }
}

extension URL {
    var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
}

extension View {
     public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
         let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
         return clipShape(roundedRect)
              .overlay(roundedRect.strokeBorder(content, lineWidth: width))
     }
 }

extension String {
    enum SearchDirection {
        case first, last
    }
    func characterIndex(of character: Character, direction: String.SearchDirection) -> Int? {
        let fn = direction == .first ? firstIndex : lastIndex
        if let stringIndex: String.Index = fn(character) {
            let index: Int = distance(from: startIndex, to: stringIndex)
            return index
        }  else {
            return nil
        }
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
